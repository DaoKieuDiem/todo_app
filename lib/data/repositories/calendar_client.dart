import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarClient {
  static const _scopes = [CalendarApi.CalendarScope];

  bool insert(String title, DateTime startTime, DateTime endTime) {
    final _clientID = ClientId(
        '948524315602-3a1gqph5v8ah4irfkpncq0a4bffuv0vp'
            '.apps.googleusercontent.com',
        '');
    clientViaUserConsent(_clientID, _scopes, prompt).then((AuthClient client) {
      final calendar = CalendarApi(client);
      calendar.calendarList
          .list()
          .then((value) => debugPrint('VAL________$value'));

      const calendarId = 'primary';
      final event = Event()..summary = title;

      final start = EventDateTime()
        ..dateTime = startTime
        ..timeZone = 'GMT+07:00';
      event.start = start;

      final end = EventDateTime()
        ..dateTime = endTime
        ..timeZone = 'GMT+07:00';
      event.end = end;
      try {
        calendar.events.insert(event, calendarId).then((value) {
          if (value.status == 'confirmed') {
            log('Event added in google calendar');
            return true;
          } else {
            log('Unable to add event in google calendar');
            return false;
          }
        });
      } catch (e) {
        log('Error creating event $e');
        return false;
      }
    });
  }

  Future<void> prompt(String url) async {
    debugPrint('Please go to the following URL and grant access:');
    debugPrint('  => $url');
    debugPrint('');

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }
}
