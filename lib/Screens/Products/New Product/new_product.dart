import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speedydrop/Screens/Loading/loading.dart';
import 'package:speedydrop/Services/Database/database.dart';
import '../../../Constants/constants.dart';
import '../../../Services/Auth/auth.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  // Variables

  final Color _orangeColor = Colors.orange.shade800;
  List<File> _images = [];
  final int numberOfImages = 5;
  String _error = '';
  double imagesHeight = 110.0;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final Auth_Service _auth_service = Auth_Service();
  String _productName = '';
  String _description = '';
  double _price = 0.0;
  int _quantity = 0;

  String _selectedCategory = 'not-selected';
  bool isLoading = false;

// Functions
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _quantityController.text = _quantity.toString();
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 0) {
        setState(() {
          _quantity--;
          _quantityController.text = _quantity.toString();
        });
      }
    });
  }

  void _updateQuantityFromField() {
    setState(() {
      _quantity = int.tryParse(_quantityController.text) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading == false) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back,
              color: Colors.white,
              size: 30.0,),
          ),
          title: const Text('Add New Product',
            style: TextStyle(color: Colors.white),),
          centerTitle: true,
          backgroundColor: _orangeColor,

        ),
        backgroundColor: Colors.orange.shade50,
        body: SingleChildScrollView(
          child: Column(

            children: [
              const SizedBox(height: 10.0,),
              const Text('Product Details',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),),
              const SizedBox(height: 10.0,),
              Container(
                height: imagesHeight,
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0),
                child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                    itemCount: _images.length == 0 ? 2 : _images.length + 1, // for the add button
                    itemBuilder: (context, index) {
                      if (_images.length == 0 && index == 0) {
                        // Display transparent box
                        return Container(
                          color: Colors.transparent,
                        );
                      } else if (_images.isEmpty && index == 1) {
                        // Display Add Button
                        return GestureDetector(
                          onTap: () {
                            if (_images.length < numberOfImages) {
                              _getImage();
                              if (_images.length == 2 && imagesHeight == 110) {
                                setState(() {
                                  imagesHeight = 220;
                                });
                              }
                            } else {
                              log('Maximum images limit has been reached');
                              setState(() {
                                _error = 'Maximum images limit reached!';
                              });
                            }
                          },
                          child: Container(
                            color: Colors.grey.shade300,
                            child: _images.length < numberOfImages
                                ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 10.0,),
                                Icon(Icons.add, size: 30.0,),
                                Text('Upload Image',
                                  style: TextStyle(fontSize: 12.0),),
                              ],
                            )
                                : const Icon(Icons.error),
                          ),
                        );
                      } else if (_images.length > 0 && index == _images.length) {
                        // Last item is the Add Button
                        return GestureDetector(
                          onTap: () {
                            if (_images.length < numberOfImages) {
                              _getImage();
                              if (_images.length == 2 && imagesHeight == 110) {
                                setState(() {
                                  imagesHeight = 220;
                                });
                              }
                            } else {
                              log('Maximum images limit has been reached');
                              setState(() {
                                _error = 'Maximum images limit reached!';
                              });
                            }
                          },
                          child: Container(
                            color: Colors.grey.shade300,
                            child: _images.length < numberOfImages
                                ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 10.0,),
                                Icon(Icons.add, size: 30.0,),
                                Text('Upload Image',
                                  style: TextStyle(fontSize: 12.0),),
                              ],
                            )
                                : const Icon(Icons.error),
                          ),
                        );
                      } else {
                        // Display the selected Images
                        return Stack(
                          children: [
                            Center(
                              child: Image.file(
                                _images[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 3,
                              right: 3,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _error = '';
                                    if (_images.length == 3 &&
                                        imagesHeight == 220) {
                                      setState(() {
                                        imagesHeight = 110;
                                      });
                                    }
                                    _images.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: const Icon(Icons.close,
                                    color: Colors.white,
                                    size: 18.0,),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    }
                ),


              ),
              Text(_error, style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),),
              const SizedBox(height: 5.0,),
              Form(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _productNameController,
                        decoration: InputDecoration(
                          hintText: 'your_product_name',
                          labelText: 'Product Name',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2.0,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _orangeColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          labelStyle: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15.0),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Enter Product Name' : null;
                        },
                      ),
                      const SizedBox(height: 10.0,),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'product_description',
                          labelText: 'Description',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2.0,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _orangeColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          labelStyle: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15.0),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Enter Description' : null;
                        },
                      ),
                      const SizedBox(height: 10.0,),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          hintText: 'i.e 976.00',
                          labelText: 'Price',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2.0,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _orangeColor,
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          labelStyle: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15.0),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Enter Price' : null;
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 10.0,),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Select a category',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 2.0,
                              )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _orangeColor,
                              width: 2.0,
                            ),
                          ),
                          labelStyle: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15.0),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        items: ['not-selected', ...categories].map<
                            DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10.0,),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove, color: Colors.red, size: 30.0,),
                            onPressed: _decrementQuantity,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _updateQuantityFromField(),
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                hintText: 'Enter the quantity of the product',
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 2.0,
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _orangeColor,
                                    width: 2.0,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 15.0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the quantity';
                                }
                                return null;
                              },

                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add, color: Colors.green, size: 30.0,),
                            onPressed: _incrementQuantity,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0,),
                      ElevatedButton(
                        onPressed: () async {
                          _productName = _productNameController.text;
                          _description = _descriptionController.text;
                          _price = double.tryParse(_priceController.text) ??
                              0.0;
                          _quantity = int.tryParse(_quantityController.text) ??
                              0;

                          if (_productName != '' && _quantity != 0 &&
                              _description != '' && _price != 0.0 &&
                              _selectedCategory != 'not-selected' &&
                              _images.isNotEmpty) {
                            // all field are full
                            setState(() {
                              _error = '';
                            });
                            setState(() {
                              isLoading = true;
                            });
                            bool isProductAdded = await Database_Service(
                                userId: _auth_service.getUserId())
                                .createNewProduct(
                                _images, _productName, _description, _price,
                                _quantity, _selectedCategory);
                            if (isProductAdded == true) {
                              log('Product added successfully');
                              Navigator.pop(context);
                                isLoading = false;
                            } else {
                              setState(() {
                                _error = 'Unable to add Product!';
                              });
                              log('Unable to add product');
                            }
                          } else {
                            if (_productName != '' && _quantity != 0 &&
                                _description != '' && _price != 0.0 &&
                                _selectedCategory == 'not-selected') {
                              setState(() {
                                _error = 'Please Select a Category';
                              });
                            } else {
                              // some fields are empty
                              setState(() {
                                _error = 'Please fill out all fields';
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orangeColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 5.0),
                          elevation: 4.0,
                        ),
                        child: const Text('Add Product',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return const Loading_Screen();
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _selectedCategory = 'not-selected';
  }
}