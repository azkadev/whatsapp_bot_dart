// ignore_for_file: non_constant_identifier_names 
import 'package:whatsapp_client/whatsapp_client.dart';
import 'dart:io';
import "package:whatsapp_client/scheme/update/raw_message.dart" as wa_scheme_raw_message;

void main(List<String> args) async {
  WhatsApp wa = WhatsApp();
  wa.on(wa.event_data_update, null, (update) async {
    try {
      if (update is Map) {
        if (update["@type"] == "updateAuthorization") {
          print(update);
          if (update["authorization"] is Map) {
            Map authorization = update["authorization"];
            if (authorization["@type"] == "authQrCode") {
              String qr_data = authorization["data"];
              File fileOutPut = File("./qr_code.png");
              await WhatsAppQr.encode(text: qr_data, fileOutPut: fileOutPut, padding: 10);
            }
          }
        }
        if (update["@type"] == "updateNewMessage") {
          wa_scheme_raw_message.UpdateNewMessage updateNewMessage = wa_scheme_raw_message.UpdateNewMessage(update);
          wa_scheme_raw_message.Message message = updateNewMessage.message;
          if (updateNewMessage.message.id.fromMe == false) {
            
            String country_code = message.id.remote!.substring(0, 1);
            String phone_number = message.id.remote!.replaceAll(RegExp(r"(@.*)", caseSensitive: false), "");
            phone_number = phone_number.replaceAll(RegExp("^${country_code}", caseSensitive: false), "");
            late String text = "";
            late String caption = "";
            if (message.type == "chat") {
              text = message.body ?? "";
            }
            if (message.caption != null) {
              caption = message.caption ?? "";
            }
            print(message.toString());
            if (text.isNotEmpty) {
              if (RegExp(r"/start", caseSensitive: false).hasMatch(text)) {
                return await wa.invoke(
                  method: "sendMessage",
                  parameters: {
                    "chat_id": message.id.remote,
                    "text": "Hai perkenalkan saya adalah robot",
                  },
                );
              }

              if (RegExp(r"/ping", caseSensitive: false).hasMatch(text)) {
                return await wa.invoke(
                  method: "sendMessage",
                  parameters: {
                    "chat_id": message.id.remote,
                    "text": "Pong",
                  },
                );
              }
              if (RegExp(r"/info", caseSensitive: false).hasMatch(text)) {
                ///

              }
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  });

  await wa.initIsolate(); // add  this for create new client
  print("init isolate");
}
