import os
from flask import Flask, request, jsonify
from dotenv import load_dotenv
from PyPDF2 import PdfReader
from langchain.text_splitter import CharacterTextSplitter
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import FAISS
from langchain.chat_models import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationalRetrievalChain
from flask_cors import CORS
from werkzeug.utils import secure_filename
import re
import warnings

warnings.filterwarnings("ignore", category=UserWarning)  # Suppress PyPDF2 warnings

# Initialize Flask app
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # Enable CORS for Flutter

# Load environment variables
load_dotenv()

# Directory to store the embeddings
EMBEDDINGS_DB = "EmbeddingsDB"
os.makedirs(EMBEDDINGS_DB, exist_ok=True)

# Helper functions (unchanged from your implementation)
def get_saved_pdf_names():
    return [name for name in os.listdir(EMBEDDINGS_DB) if os.path.isdir(os.path.join(EMBEDDINGS_DB, name))]

def load_vectorstore(pdf_name):
    vectorstore = FAISS.load_local(
        os.path.join(EMBEDDINGS_DB, pdf_name),
        OpenAIEmbeddings(),
        allow_dangerous_deserialization=True
    )
    return vectorstore

def get_pdf_text(pdf_docs):
    raw_text = ""
    for pdf_file in pdf_docs:
        try:
            reader = PdfReader(pdf_file)
            for page in reader.pages:
                text = page.extract_text()
                if text:
                      raw_text += text
        except Exception as e:
               print(f"Error extracting text from page: {e}")
        except Exception as e:
            print(f"Error parsing PDF: {e}")
    return raw_text

def get_text_chunks(text):
    text_splitter = CharacterTextSplitter(
        separator="\n",
        chunk_size=1000,
        chunk_overlap=200,
        length_function=len
    )
    return text_splitter.split_text(text)

def get_vectorstore(text_chunks, pdf_name):
    if not text_chunks:
        raise ValueError("No text chunks available for embeddings")
    embeddings = OpenAIEmbeddings()
    vectorstore = FAISS.from_texts(texts=text_chunks, embedding=embeddings)
    save_path = os.path.join(EMBEDDINGS_DB, pdf_name)
    os.makedirs(save_path, exist_ok=True)
    vectorstore.save_local(save_path)
    return vectorstore

def get_conversation_chain(vectorstore):
    llm = ChatOpenAI()
    memory = ConversationBufferMemory(memory_key='chat_history', return_messages=True)
    return ConversationalRetrievalChain.from_llm(
        llm=llm,
        retriever=vectorstore.as_retriever(),
        memory=memory,
    )

# Routes (unchanged except for adding error logging)
@app.route('/')
def index():
    return jsonify({"message": "Flask backend is running"})

@app.route('/upload', methods=['POST'])
def upload_pdf():

    if 'pdf_files' not in request.files:
        return jsonify({"error": "No files uploaded"}), 400

    pdf_files = request.files.getlist('pdf_files')
    if not pdf_files:
        return jsonify({"error": "No valid PDF files uploaded"}), 400

    try:

         # Get the name of the first PDF (assuming one file for simplicity)
        pdf_name = os.path.splitext(secure_filename(pdf_files[0].filename))[0]

        # Check if embeddings already exist
        if pdf_name in get_saved_pdf_names():
            # Load the existing vectorstore
            vectorstore = load_vectorstore(pdf_name)
            app.config['CONVERSATION_CHAIN'] = get_conversation_chain(vectorstore)
            return jsonify({"message": f"Embeddings for {pdf_name} are already available and loaded."}), 200
    
        raw_text = get_pdf_text(pdf_files)
        if not raw_text:
             return jsonify({"error": "No text could be extracted from the PDF"}), 400
        text_chunks = get_text_chunks(raw_text)
        vectorstore = get_vectorstore(text_chunks, pdf_name)
        
        app.config['CONVERSATION_CHAIN'] = get_conversation_chain(vectorstore)
        return jsonify({"message": f"Embeddings created for {pdf_name}","answer": "Upload completed."}), 200
    except Exception as e:
        print(f"Error during PDF processing: {e}")
        return jsonify({"error": "Error during PDF processing"}), 500

@app.route('/ask_question', methods=['POST'])
def ask_question():
    
    print("Headers:", request.headers)
    print("Content-Type:", request.content_type)
    print("Raw Data:", request.data)  # Inspect raw payload
    
    if not re.match(r'^application/json(; charset=[\w-]+)?$', request.content_type, re.IGNORECASE):
        return jsonify({"error": "Invalid content type. Expected application/json"}), 415
    
    conversation_chain = app.config.get('CONVERSATION_CHAIN')
    if not conversation_chain:
         return jsonify({'error': 'No conversation chain available. Please upload a PDF first.'}), 400

    data = request.get_json()  # Ensure it gets JSON data
    
    
    question = data.get('question')
    print("Parsed JSON:", data)
    if not question:
        return jsonify({'error': 'No question provided'}), 400

    conversation_chain = app.config['CONVERSATION_CHAIN']
    try:
        response = conversation_chain.invoke({'question': question})
        answer = response.get('answer', '').strip()
        if not answer or "unknown" in answer.lower():  # Adjust this check based on your logic
            answer = "I do not have information about that. Please try asking a different question."
        return jsonify({'answer': response['answer']}), 200
    except Exception as e:
        print(f"Error during question answering: {e}")
        return jsonify({"error": "Error during question answering"}), 500

if __name__ == '__main__':
    app.run(debug=True)
