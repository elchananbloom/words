import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstImage extends StatefulWidget {
  const FirstImage({
    super.key,
  });

  @override
  _FirstImageState createState() => _FirstImageState();
}

class _FirstImageState extends State<FirstImage> {
  bool isTakeFirstImage = false;

  @override
  void initState() {
    super.initState();
    //isTakeFirstImage from shared preferences
    getIsTakeFirstImage();
  }

  void getIsTakeFirstImage() async {
    await SharedPreferences.getInstance().then((prefs) {
      isTakeFirstImage = prefs.getBool('isTakeFirstImage') ?? false;
      setState(() {
        isTakeFirstImage = isTakeFirstImage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Take First Image'),
      trailing: const Icon(Icons.camera_alt),
      leading: Checkbox(
        value: isTakeFirstImage,
        onChanged: (value) {
          setState(() {
            setIsTakeFirstImage(value);
          });
        },
      ),
      onTap: () {
        //pop up dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Take First Image',
                textAlign: TextAlign.center,
              ),
              content: const Text(
                  'If you want to take the first image of the word from the internet, check this box.',
                  textAlign: TextAlign.center),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        setState(() {
          setIsTakeFirstImage(!isTakeFirstImage);
        });
      },
    );
  }

  void setIsTakeFirstImage(bool? value) {
    isTakeFirstImage = value!;
    //save isTakeFirstImage to shared preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isTakeFirstImage', isTakeFirstImage);
    });
  }
}
