import json
import os
import logging

import functions_framework
from google.cloud import documentai_v1 as documentai
from google.cloud import storage
from google.api_core.exceptions import GoogleAPIError

logging.basicConfig(level=logging.INFO)

storage_client = storage.Client()
docai_client = documentai.DocumentProcessorServiceClient()


@functions_framework.cloud_event
def process_pdf(cloud_event):
    data = cloud_event.data
    bucket_name = data.get("bucket")
    file_name = data.get("name")

    PROCESSOR_NAME = os.environ.get("PROCESSOR_NAME")
    INVOICE_BUCKET = os.environ.get("INVOICE_BUCKET")
    COMPANY_DATA_BUCKET = os.environ.get("COMPANY_DATA_BUCKET")

    if not all([PROCESSOR_NAME, INVOICE_BUCKET, COMPANY_DATA_BUCKET]):
        logging.error("Critical: Missing one or more required environment variables.")
        return

    if not file_name or not file_name.lower().endswith('.pdf'):
        logging.info(f"Skipping {file_name}: Not a PDF document.")
        return

    gcs_uri = f"gs://{bucket_name}/{file_name}"
    logging.info(f"Processing document: {gcs_uri}")

    try:
        gcs_document = documentai.GcsDocument(gcs_uri=gcs_uri, mime_type="application/pdf")
        request = documentai.ProcessRequest(name=PROCESSOR_NAME, gcs_document=gcs_document)

        result = docai_client.process_document(request=request)
        extracted_text = result.document.text
        text_lower = extracted_text.lower()

        is_invoice = "invoice" in text_lower
        is_betterme = "betterme" in text_lower

        if is_invoice:
            target_bucket_name = INVOICE_BUCKET
            doc_type = "Invoice"
        elif is_betterme:
            target_bucket_name = COMPANY_DATA_BUCKET
            doc_type = "Company Data"
        else:
            logging.info(f"Document '{file_name}' did not match target keywords. Skipping routing.")
            return

        output_json = {
            "source_file": file_name,
            "document_type": doc_type,
            "extracted_text": extracted_text
        }

        target_bucket = storage_client.bucket(target_bucket_name)
        json_filename = f"{file_name}.json"
        target_blob = target_bucket.blob(json_filename)

        target_blob.upload_from_string(
            data=json.dumps(output_json, indent=2),
            content_type="application/json"
        )
        logging.info(f"Successfully saved {doc_type} data to gs://{target_bucket_name}/{json_filename}")

    except GoogleAPIError as api_err:
        logging.error(f"GCP API Error while processing {file_name}: {api_err}")
    except Exception as e:
        logging.error(f"Unexpected error processing {file_name}: {e}")
