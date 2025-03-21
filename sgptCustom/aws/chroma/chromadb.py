import chromadb
import os

# Set the environment variable for ChromaDB
chromahost = os.getenv("CHROMA_DB_HOST")
print(chromahost)
chroma_client = chromadb.HttpClient(
  host=chromahost,
  port=8000
)
# chroma_client = chromadb.Client(
#   host=chromahost,
#   port=8000,
# )
chroma_client.heartbeat()
