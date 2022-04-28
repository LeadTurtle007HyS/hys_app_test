import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as places;
import 'package:location/location.dart';

class MapLocation extends StatefulWidget {
  double curr_lat;
  double curr_long;
  MapLocation(this.curr_lat, this.curr_long);

  @override
  _MapLocationState createState() =>
      _MapLocationState(this.curr_lat, this.curr_long);
}

const kGoogleApiKey = "AIzaSyDs_6rLzCiSztuBcuEUgNypSQ-9xc0-dfQ";
places.GoogleMapsPlaces _places =
    places.GoogleMapsPlaces(apiKey: kGoogleApiKey);
LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
GoogleMapController _controller;
Location _location = Location();
Map<String, double> currentLoc;
Map<MarkerId, Marker> markers = {};

class _MapLocationState extends State<MapLocation> {
  double curr_lat;
  double curr_long;
  _MapLocationState(this.curr_lat, this.curr_long);

  void _onMapCreated(GoogleMapController _cntlr) {
   
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(this.curr_lat, this.curr_long)));});
        // .newCameraPosition(
          //CameraPosition(target: LatLng(this.curr_lat, this.curr_long), zoom: 15),
        
    }
  

  @override
  void initState() {
    //_onMapCreated(_controller);
    super.initState();
    _addMarker(
        LatLng(this.curr_lat, this.curr_long), "origin", BitmapDescriptor.defaultMarker);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: LatLng(curr_lat, curr_long)),
                  mapType: MapType.normal,
                  //onMapCreated: _onMapCreated,
                  myLocationEnabled: true,onMapCreated: (GoogleMapController controller) {
        if( _controller == null ){
      _controller = controller;}},markers: Set<Marker>.of(markers.values)
                ))));}
                  // markers: Set<Marker>.of(markers.values),
                
  

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }
}
