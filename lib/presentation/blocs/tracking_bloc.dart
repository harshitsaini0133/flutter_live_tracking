import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/location_model.dart';
import '../../data/models/route_model.dart';
import '../../domain/repositories/tracking_repository.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackingRepository repository;
  StreamSubscription? _sub;
  RouteModel? route;

  TrackingBloc({required this.repository}) : super(TrackingInitial()) {
    on<LoadRoute>(_onLoadRoute);
    on<StartTracking>(_onStartTracking);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<UpdateStatus>(_onUpdateStatus);
    on<StopTracking>(_onStopTracking);
  }

  Future<void> _onLoadRoute(
      LoadRoute event, Emitter<TrackingState> emit) async {
    emit(TrackingLoading());
    route = await repository.loadRouteFromAsset();
    emit(RouteLoaded(route!));
  }

  Future<void> _onStartTracking(
      StartTracking event, Emitter<TrackingState> emit) async {
    emit(TrackingStarted());
    // ensure repository started/initialized (so stream has data)
    try {
      await repository.start();
    } catch (e) {
      // emit(TrackingError('Failed to start repository: $e'));
      return;
    }

    _sub = repository.locationStream.listen((loc) {
      add(UpdateLocationEvent(loc));
      add(UpdateStatus(loc.status));
    }, onDone: () {
      add(StopTracking());
    }, onError: (err) {
      // emit(TrackingError(err.toString()));
    });
  }


  void _onUpdateLocation(
      UpdateLocationEvent event, Emitter<TrackingState> emit) {
    final loc = event.location;
    emit(LocationUpdated(loc, route));
  }

  void _onUpdateStatus(UpdateStatus event, Emitter<TrackingState> emit) {
    emit(StatusUpdated(event.status));
  }

  Future<void> _onStopTracking(
      StopTracking event, Emitter<TrackingState> emit) async {
    await _sub?.cancel();
    repository.stop();
    emit(TrackingStopped());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    repository.stop();
    return super.close();
  }
}

abstract class TrackingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRoute extends TrackingEvent {}

class StartTracking extends TrackingEvent {}

class UpdateLocationEvent extends TrackingEvent {
  final LocationModel location;
  UpdateLocationEvent(this.location);
  @override
  List<Object?> get props => [location];
}

class UpdateStatus extends TrackingEvent {
  final String status;
  UpdateStatus(this.status);
  @override
  List<Object?> get props => [status];
}

class StopTracking extends TrackingEvent {}

abstract class TrackingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {}

class TrackingLoading extends TrackingState {}

class RouteLoaded extends TrackingState {
  final dynamic route; // RouteModel
  RouteLoaded(this.route);
  @override
  List<Object?> get props => [route];
}

class TrackingStarted extends TrackingState {}

class LocationUpdated extends TrackingState {
  final dynamic location; // LocationModel
  final dynamic route; // RouteModel
  LocationUpdated(this.location, this.route);
  @override
  List<Object?> get props => [location, route];
}

class StatusUpdated extends TrackingState {
  final String status;
  StatusUpdated(this.status);
  @override
  List<Object?> get props => [status];
}

class TrackingStopped extends TrackingState {}
