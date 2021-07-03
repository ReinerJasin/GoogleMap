import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap/directions_model.dart';
import 'package:googlemap/directions_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(-5.1295478, 119.4183395), zoom: 15);

  late GoogleMapController _googleMapController;
  Marker _origin = const Marker(markerId: MarkerId("empty"));
  Marker _destination = const Marker(markerId: MarkerId("empty"));
  bool originChecker = false;
  bool destinationChecker = false;

  late Directions _info;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              _origin,
              _destination,
            },
            polylines: {
              Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList())
            },
            onLongPress: _addMarker,
          ),
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                (originChecker == false)
                    ? Container()
                    : ElevatedButton(
                        onPressed: () {
                          _googleMapController.animateCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                            target: _origin.position,
                            zoom: 15,
                          )));
                          setState(() {});
                        },
                        child: Text('Origin')),
                SizedBox(width: 24),
                (destinationChecker == false)
                    ? Container()
                    : ElevatedButton(
                        onPressed: () {
                          _googleMapController.animateCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                            target: _destination.position,
                            zoom: 15,
                          )));
                          setState(() {});
                        },
                        child: Text('Destination')),
              ],
            ),
          ),
          Positioned(
            top: 20.0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.yellowAccent,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  )
                ],
              ),
              child: Text(
                '${_info.totalDistance}, ${_info.totalDuration}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          _info != null
              ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
              : CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (originChecker == true && destinationChecker == true) {
      originChecker = false;
      destinationChecker = false;
      _origin = const Marker(markerId: MarkerId("empty"));
      _destination = const Marker(markerId: MarkerId("empty"));
    }

    if (originChecker == false) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );

        originChecker = true;

        // _info = null;
      });
    } else {
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      destinationChecker = true;

      final directions = await DirectionsRepository()
          .getDirections(origin: _origin.position, destination: pos);
      setState(() {
        _info = directions;
      });
    }
  }
}
