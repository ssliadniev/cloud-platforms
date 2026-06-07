import logging
import os

import functions_framework
from google.cloud import documentai_v1 as documentai
from google.cloud import storage

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

PROJECT_ID = os.environ.get("PROJECT_ID")
LOCATION = os.environ.get("LOCATION", "us")
PROCESSOR_ID = os.environ.get("PROCESSOR_ID")
OUTPUT_BUCKET = os.environ.get("OUTPUT_BUCKET")


@functions_framework.cloud_event
def process_invoice(cloud_event):
    """
    Triggered by a change to a Cloud Storage bucket.
    """

    data = cloud_event.data
    input_bucket = data["bucket"]
    file_name = data["name"]

    logger.info(f"Trigger received. Processing file: {file_name} from bucket: {input_bucket}")

    try:
        docai_client = documentai.DocumentProcessorServiceClient()
        storage_client = storage.Client()

        gcs_uri = f"gs://{input_bucket}/{file_name}"

        name = docai_client.processor_path(PROJECT_ID, LOCATION, PROCESSOR_ID)
        request = documentai.ProcessRequest(
            name=name,
            gcs_document=documentai.GcsDocument(
                gcs_uri=gcs_uri,
                mime_type="application/pdf"
            )
        )

        logger.info("Sending document to Document AI for OCR processing...")
        result = docai_client.process_document(request=request)
        document = result.document

        document_json = documentai.Document.to_json(document)

        output_file_name = f"{file_name.rsplit('.', 1)[0]}.json"

        out_bucket = storage_client.bucket(OUTPUT_BUCKET)
        blob = out_bucket.blob(output_file_name)

        blob.upload_from_string(document_json, content_type="application/json")
        logger.info(f"Success! Saved parsed data to gs://{OUTPUT_BUCKET}/{output_file_name}")

    except Exception as e:
        logger.error(f"Failed to process {file_name}: {str(e)}", exc_info=True)
        raise
