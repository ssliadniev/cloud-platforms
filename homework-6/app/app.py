import os

import streamlit as st
from dotenv import load_dotenv

load_dotenv()

from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_classic.chains.retrieval import create_retrieval_chain
from langchain_community.document_loaders import PDFMinerLoader
from langchain_core.prompts import ChatPromptTemplate
from langchain_google_community import BigQueryVectorStore
from langchain_google_community.gcs_directory import GCSDirectoryLoader
from langchain_google_vertexai import ChatVertexAI, VertexAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

PROJECT_ID = os.environ.get("PROJECT_ID")
REGION = os.environ.get("REGION")
BUCKET_NAME = os.environ.get("BUCKET_NAME")
DATASET_NAME = "company_data_rag"
TABLE_NAME = "pdf_embeddings"


@st.cache_resource
def get_models():
    embeddings = VertexAIEmbeddings(model_name="text-embedding-004", project=PROJECT_ID)
    llm = ChatVertexAI(model_name="gemini-3.5-flash", project=PROJECT_ID, location="global", temperature=0)
    return embeddings, llm


embeddings, llm = get_models()


def ingest_documents():
    loader = GCSDirectoryLoader(
        project_name=PROJECT_ID,
        bucket=BUCKET_NAME,
        loader_func=PDFMinerLoader
    )

    documents = loader.load()
    if not documents:
        return False, "No documents found in GCS Bucket."

    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100)
    docs = text_splitter.split_documents(documents)

    for doc in docs:
        doc.metadata = {
            "metadata_source": doc.metadata.get("source", "Unknown Document")
        }

    vector_store = BigQueryVectorStore(
        project_id=PROJECT_ID,
        dataset_name=DATASET_NAME,
        table_name=TABLE_NAME,
        location=REGION,
        embedding=embeddings,
        doc_id_field="chunk_id"
    )
    vector_store.add_documents(docs)

    return True, f"Successfully ingested {len(docs)} chunks into BigQuery!"


def get_vector_store():
    return BigQueryVectorStore(
        project_id=PROJECT_ID,
        dataset_name=DATASET_NAME,
        table_name=TABLE_NAME,
        location=REGION,
        embedding=embeddings,
    )


st.title("📄 Company Data RAG Chatbot")
st.markdown("Powered by **Vertex AI Gemini**, **BigQuery Vector Search**, and **Cloud Run**.")

with st.sidebar:
    st.header("Admin Controls")
    st.info(f"Connected to Bucket: `{BUCKET_NAME}`")

    if st.button("Ingest/Sync PDFs from GCS"):
        with st.spinner("Embedding documents... This may take a minute."):
            success, msg = ingest_documents()

            if success:
                st.success(msg)
            else:
                st.error(msg)

if "messages" not in st.session_state:
    st.session_state.messages = []

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("Ask a question about the Company Data..."):
    st.session_state.messages.append({"role": "user", "content": prompt})

    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            try:
                vector_store = get_vector_store()
                retriever = vector_store.as_retriever(search_kwargs={"k": 3})

                system_prompt = (
                    "You are an assistant for question-answering tasks about Company Data. "
                    "Use the following pieces of retrieved context to answer the question. "
                    "If you don't know the answer, say that you don't know.\n\n"
                    "Context:\n{context}"
                )

                chat_prompt = ChatPromptTemplate.from_messages([
                    ("system", system_prompt),
                    ("human", "{input}")
                ])

                question_answer_chain = create_stuff_documents_chain(llm, chat_prompt)
                rag_chain = create_retrieval_chain(retriever, question_answer_chain)

                response = rag_chain.invoke({"input": prompt})
                answer = response["answer"]

                st.markdown(answer)
                st.session_state.messages.append({"role": "assistant", "content": answer})

            except Exception as e:
                st.error(f"Error querying the database: {e}. Did you click 'Ingest' first?")
