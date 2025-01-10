import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart'; 
import 'package:http/http.dart' as http;
import 'package:my_finel_project/SighInPage.dart';
import 'dart:convert'; // For jsonEncode
import 'dart:io'; 
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'Services/auth.dart'; 
import 'package:http_parser/http_parser.dart';



class PdfChatbotPage extends StatefulWidget {
  @override
  _PdfChatbotPageState createState() => _PdfChatbotPageState();
}

class _PdfChatbotPageState extends State<PdfChatbotPage> {
  AuthServices _auth = AuthServices();
  final TextEditingController _questionController = TextEditingController();
  String FileName ="";
  String? _pdfPath;
  String _answer = "";
  List<Map<String, String>> chatHistory = [];
  bool _isLoading = false;
  bool pdfUploaded = false;

  
  Future<void> uploadPdf() async {
    try {
      if (kIsWeb) {
        
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null && result.files.isNotEmpty) {
          final bytes = result.files.single.bytes; 
          final fileName = result.files.single.name;
          FileName = fileName;
          print('Selected PDF (Web): $fileName');

         
          await uploadToServer(bytes!, fileName);
          setState(() {
            pdfUploaded = true;
            _questionController.text = ''; 
          });
        } else {
          setState(() {
            pdfUploaded = false;
            _questionController.text = ''; 
          });
        }
      } else {
        // For Mobile/Desktop
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final filePath = result.files.single.path!;
          final fileName = basename(filePath);
          print('Selected PDF (Mobile/Desktop): $fileName');

          
          final fileBytes = File(filePath).readAsBytesSync();
          await uploadToServer(fileBytes, fileName);
          setState(() {
            pdfUploaded = true;
            _questionController.text = ''; 
          });
        } else {
          setState(() {
            pdfUploaded = false;
            _questionController.text = ''; 
          });
        }
      }
    } on PlatformException catch (e) {
      print("File Picker error: $e");
    }finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  
  Future<void> uploadToServer(Uint8List fileBytes, String fileName) async {
    final Uri url = Uri.parse('http://*******:5000/upload'); 
    final request = http.MultipartRequest('POST', url);

    
    final multipartFile = http.MultipartFile.fromBytes('pdf_files', fileBytes, filename: fileName,contentType: MediaType('application', 'pdf'));

    
    request.files.add(multipartFile);

    
    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        print("File uploaded successfully!");
        setState(() {
          pdfUploaded = true;
          _questionController.text = ''; 
          chatHistory.add({"bot": "File uploaded successfully!"}); 
        });
        

        final data = jsonDecode(responseData); 

        if (data.containsKey('answer') && data['answer'] is String) {
        setState(() {
          chatHistory.add({"bot": data['answer']});  
        });
        } else {
          print("Invalid response format or missing 'answer' key: $data");
        }
      } else {
        print("Failed to upload file. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading file: $e");
    }
    finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  Future<void> handleUserInput(String question) async {
    if (_isLoading || question.isEmpty || !pdfUploaded) {
      
      if (question.isEmpty) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            SnackBar(content: Text("Please enter a question before submitting."))
        );
      }
      return; 
    }

    setState(() {
      chatHistory.add({"user": question});
      _isLoading = true;
    });

    try {
      String response = await getChatbotResponse(question); 
      setState(() {
        chatHistory.add({"bot": response});
      });
    } catch (e) {
      setState(() {
        chatHistory.add({"bot": "An error occurred. Please try again."});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    _questionController.clear(); 
  }


  Future<String> getChatbotResponse(String question) async {
    final Uri url = Uri.parse('http://*******:5000/ask_question');  
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'question': question});
    try {
      final response = await http.post(
        url,
        headers:  headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);  
        return data['answer'];
      } else if (response.statusCode == 415) {
        print('Request JSON: $body');
        print("Response body: ${response.body}");
        return 'Error: Unsupported media type. Ensure content type is JSON.';

      }else {
        return 'Error: ${response.statusCode}. Please try again.';
      }
    } catch (e) {
      return 'Error: $e. Please check your network connection.';
    }
  }

  void logout() {
    Navigator.push(context as BuildContext, MaterialPageRoute(builder: (context) => LoginPage())); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Column(
          children: [
            SizedBox(height: 4),
            Text('Chat Bot', style: TextStyle(color: Colors.purple[400])),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _auth.signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => LoginPage()));
              }
            },
            itemBuilder: (BuildContext context) {
              return {'logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice.capitalize()),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Expanded(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  final message = chatHistory[index];
                  return Row(
                    mainAxisAlignment: message.containsKey("user")
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!message.containsKey("user")) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset('assets/images/logo.jpg', height: 30),
                          ),
                        ),
                      ],
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message.containsKey("user")
                                ? Colors.purple[100]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  spreadRadius: 2),
                            ],
                          ),
                          child: Text(
                            message.values.first,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: uploadPdf,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText:
                      pdfUploaded ? 'Ask a question...' : 'Upload your PDF',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onSubmitted: (value) => handleUserInput(value),
                    enabled: pdfUploaded,
                    controller: _questionController,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed:
                  pdfUploaded ? () => handleUserInput(_questionController.text) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


extension StringCasingExtension on String {
  String capitalize() => this.isEmpty ? this : '${this[0].toUpperCase()}${this.substring(1)}';
}
