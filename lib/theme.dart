import 'package:flutter/material.dart';
import 'package:semanas/colors.dart';

var _amber = Colors.amber[400];
var _yellow = Colors.yellow;

ThemeData lightTheme = ThemeData(
    primarySwatch: _yellow,
    brightness: Brightness.light,
    textTheme:
        TextTheme(subtitle1: TextStyle(fontSize: 16, color: clear_grey)));

ThemeData darkTheme = ThemeData(
    primarySwatch: _yellow,
    brightness: Brightness.dark,
    toggleableActiveColor: _amber,
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: _amber,
        selectionColor: _amber,
        selectionHandleColor: _amber),
    primaryColor: _amber,
    colorScheme:
        ColorScheme.dark(secondary: _amber, brightness: Brightness.dark),
    textTheme: TextTheme(subtitle1: TextStyle(fontSize: 16, color: ice_white)));
