import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    on<InitMap>(_onInitMap);
    on<AnimateToLocation>(_onAnimate);
    on<UpdatePolyline>(_onUpdatePolyline);
  }

  void _onInitMap(InitMap event, Emitter<MapState> emit) {
    emit(MapReady());
  }

  void _onAnimate(AnimateToLocation event, Emitter<MapState> emit) {
    emit(CameraMoved(LatLng(event.lat, event.lng), event.zoom));
  }

  void _onUpdatePolyline(UpdatePolyline event, Emitter<MapState> emit) {
    emit(PolylineUpdated(event.points));
  }
}

abstract class MapEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitMap extends MapEvent {}

class AnimateToLocation extends MapEvent {
  final double lat;
  final double lng;
  final double zoom;
  AnimateToLocation(this.lat, this.lng, {this.zoom = 16});
  @override
  List<Object?> get props => [lat, lng, zoom];
}

class UpdatePolyline extends MapEvent {
  final List<LatLng> points;
  UpdatePolyline(this.points);
  @override
  List<Object?> get props => [points];
}

abstract class MapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapReady extends MapState {}

class CameraMoved extends MapState {
  final LatLng target;
  final double zoom;
  CameraMoved(this.target, this.zoom);
  @override
  List<Object?> get props => [target, zoom];
}

class PolylineUpdated extends MapState {
  final List<LatLng> points;
  PolylineUpdated(this.points);
  @override
  List<Object?> get props => [points];
}
