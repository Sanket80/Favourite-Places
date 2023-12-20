import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Place{
  final String id;
  final String title;
  final File image;

  Place({required this.title,required this.image}) : id = uuid.v4();
}