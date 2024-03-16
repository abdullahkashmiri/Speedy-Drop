import 'package:flutter/material.dart';


//Global Variables
String Global_error = '';

// //Global Classes
// class DropDownMenu<T> extends StatefulWidget {
//   final List<T> items;
//   final T? selectedItem;
//   final void Function(T?)? onChanged;
//
//   const DropDownMenu({
//     Key? key,
//     required this.items,
//     this.selectedItem,
//     this.onChanged,
//   }) : super(key: key);
//
//   @override
//   State<DropDownMenu<T>> createState() => _DropDownMenuState<T>();
// }
//
// class _DropDownMenuState<T> extends State<DropDownMenu<T>> {
//   T? _selectedItem;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _selectedItem = widget.selectedItem;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton(
//         value: _selectedItem,
//         items: widget.items.map((T item) {
//           return DropdownMenuItem<T>(
//             value: item,
//             child: Text(item.toString()),
//           );
//         }).toList(),
//         onChanged: (T? newValue) {
//           setState(() {
//             _selectedItem = newValue;
//             if (widget.onChanged != null) {
//               widget.onChanged!(newValue);
//             }
//           });
//         },
//     );
//   }
// }