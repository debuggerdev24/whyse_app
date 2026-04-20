import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class AppAssets {
  AppAssets._();

  // icons
  static const _iconPath = "assets/icons";
  static const splascreen = "$_iconPath/splash.svg";
  static const welcome = "$_iconPath/welcome.svg";
  static const password = "$_iconPath/password.svg";
  static const apple = "$_iconPath/apple.svg";

  static const google = "$_iconPath/google.svg";
  static const backButton = "$_iconPath/backbutton.svg";
  static const datepicker = "$_iconPath/datepicker.svg";

  static const adventure = "$_iconPath/adventure.svg";
  static const check = "$_iconPath/check.svg";
  static const comics = "$_iconPath/comics.svg";
  static const fantancy = "$_iconPath/fantancy.svg";
  static const histoy = "$_iconPath/histoy.svg";
  static const mystery = "$_iconPath/mystery.svg";
  static const nature = "$_iconPath/nature.svg";
  static const done = "$_iconPath/done.svg";
  static const science = "$_iconPath/science.svg";
  static const accepted = "$_iconPath/accepted.svg";
  static const dumble = "$_iconPath/dumble.svg";
  static const note = "$_iconPath/note.svg";
  static const star = "$_iconPath/star.svg";
  static const book = "$_iconPath/book.svg";
  static const thunder = "$_iconPath/thunder.svg";
  static const notification = "$_iconPath/notification.svg";
  static const eye = "$_iconPath/eye.svg";
  static const check1 = "$_iconPath/check1.svg";
  static const vocabulary = "$_iconPath/vocabulary.svg";
  static const pronunciation = "$_iconPath/pronunciation.svg";
  static const comprehension = "$_iconPath/comprehension.svg";
  static const readingskill = "$_iconPath/readingskill.svg";
  static const close = "$_iconPath/close.svg";
  static const bookmark = "$_iconPath/bookmark.svg";
  static const disable = "$_iconPath/disable.svg";
  static const canceloption = "$_iconPath/canceloption.svg";
  static const correctoption = "$_iconPath/correct.svg";
  static const searchIcon = "$_iconPath/searchIcons.svg";
  static const homeIcon = "$_iconPath/home.svg";
  static const shareIcon = "$_iconPath/share.svg";

  static const font = "$_iconPath/font.svg";

  // images
  static const _imagePath = "assets/images";
  static const dargon = "$_imagePath/dinosaur.png";
  static const detativeclue = "$_imagePath/detativeclue.png";
  static const hauntedhouse = "$_imagePath/hauntedhouse.png";
  static const inventions = "$_imagePath/inventions.png";
  static const space = "$_imagePath/space.png";
  static const wizard = "$_imagePath/wizard.png";
  static const success = "$_imagePath/success.png";
  static const subscriptionbackground = "$_imagePath/background.png";
  static const profile = "$_imagePath/profile.png";
  static const story1 = "$_imagePath/story1.png";
  static const story2 = "$_imagePath/story2.png";
  static const story3 = "$_imagePath/story3.png";
  static const robot = "$_imagePath/robot.png";
  static const quizcomplete = "$_imagePath/quizcomplete.png";

  static const book1 = "$_imagePath/book.png";

  static const ebook = "$_imagePath/e-book.png";
  static const pterodactylus = "$_imagePath/pterodactylus.png";
  static const quiz = "$_imagePath/quiz.png";
}

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.iconPath, {super.key, double size = 100, this.color})
    : width = size,
      height = size;
  final String iconPath;
  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      width: width,
      height: height,
      color: color,
    );
  }
}
