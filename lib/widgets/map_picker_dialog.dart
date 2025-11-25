// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapPickerDialog extends StatefulWidget {
//   final LatLng? initialPosition;
//   const MapPickerDialog({Key? key, this.initialPosition}) : super(key: key);

//   @override
//   State<MapPickerDialog> createState() => _MapPickerDialogState();
// }

// class _MapPickerDialogState extends State<MapPickerDialog> {
//   LatLng? _pickedPosition;
//   GoogleMapController? _mapController;

//   @override
//   void initState() {
//     super.initState();
//     _pickedPosition = widget.initialPosition ??
//         const LatLng(20.5937, 78.9629); // Default: India
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: SizedBox(
//         width: 350,
//         height: 450,
//         child: Column(
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(16)),
//                 child: GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: _pickedPosition!,
//                     zoom: 14,
//                   ),
//                   onMapCreated: (controller) => _mapController = controller,
//                   onTap: (pos) {
//                     setState(() => _pickedPosition = pos);
//                   },
//                   markers: _pickedPosition == null
//                       ? {}
//                       : {
//                           Marker(
//                             markerId: const MarkerId('picked'),
//                             position: _pickedPosition!,
//                           ),
//                         },
//                   myLocationButtonEnabled: true,
//                   myLocationEnabled: true,
//                   zoomControlsEnabled: true,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_pickedPosition != null) {
//                           Navigator.of(context).pop(_pickedPosition);
//                         }
//                       },
//                       child: const Text('Select'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
