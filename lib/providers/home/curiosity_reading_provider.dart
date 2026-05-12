import 'package:flutter/foundation.dart';

class CuriosityReadingProvider extends ChangeNotifier {
  List<Map<String, dynamic>> curiosityReadingList = [
    {
      "title": "How does rainfall happen?",
      "imageUrl":
          "https://images.pexels.com/photos/29823411/pexels-photo-29823411.jpeg?_gl=1*1pxsnom*_ga*MTczMTg2ODY3LjE3NzY5MjE2NTA.*_ga_8JE65Q40S6*czE3NzY5MjE2NTAkbzEkZzEkdDE3NzY5MjE3MjUkajUxJGwwJGgw",
      "description":
          "Rainfall begins with the water cycle, a continuous process where water moves between the Earth's surface and the atmosphere. Heat from the sun causes water from oceans, rivers, and lakes to evaporate into vapor and rise into the air.\n\n"
          "As this warm vapor rises higher, it encounters cooler temperatures. This causes the vapor to condense into tiny droplets, forming clouds. These droplets are extremely small at first and remain suspended in the air.\n\n"
          "Over time, more and more droplets collide and combine, growing larger and heavier. When they become too heavy for the air to support, gravity pulls them down to Earth as rain.\n\n"
          "Rainfall plays a vital role in maintaining life on Earth. It refills freshwater sources, nourishes plants, and helps regulate global temperatures.",
      "fact":
          "The largest raindrop ever recorded was 8.8 millimeters in diameter, which is about the size of a grape!",
    },
    {
      "title": "Why do volcanoes erupt?",
      "imageUrl": "https://wallpapercave.com/wp/wp5814522.jpg",
      "description":
          "Deep beneath the Earth's surface lies magma, a hot, molten mixture of rock, gases, and minerals. This magma forms due to intense heat and pressure within the Earth's mantle.\n\n"
          "Sometimes, pressure builds up inside the Earth, forcing magma to move upward through cracks in the crust. As it rises, gases trapped inside the magma expand, increasing the pressure even more.\n\n"
          "When this pressure becomes too great, it causes an eruption. Magma bursts out onto the surface as lava, along with ash, steam, and gases, creating a volcanic eruption.\n\n"
          "Volcanoes can be both destructive and beneficial. While eruptions can damage nearby areas, they also create new land and enrich the soil, making it fertile for agriculture.",
      "fact":
          "The tallest volcano in the world is Mount Etna, which stands at 1,420 meters (4,800 feet) tall.",
    },
    {
      "title": "What makes the northern lights glow?",
      "imageUrl": "https://wallpapercave.com/uwp/uwp4969140.png",
      "description":
          "The Northern Lights, also known as auroras, are one of the most beautiful natural light displays on Earth. They occur high in the atmosphere near the polar regions.\n\n"
          "The process begins with the sun, which constantly releases charged particles into space. These particles travel toward Earth carried by solar winds.\n\n"
          "When these particles collide with gases like oxygen and nitrogen in the Earth's atmosphere, energy is released in the form of light. This creates glowing patterns in the sky.\n\n"
          "Different gases produce different colors. Oxygen can create green or red lights, while nitrogen can produce blue or purple hues, making each aurora unique.",
      "fact":
          "The Northern Lights are most commonly seen in regions close to the Arctic and Antarctic circles.",
    },
    {
      "title": "Can animals predict earthquakes?",
      "imageUrl": "https://wallpapercave.com/wp/wp14448779.jpg",
      "description":
          "For centuries, people have reported unusual animal behavior before earthquakes. Dogs barking excessively, birds flying erratically, and fish jumping out of water are some commonly observed signs.\n\n"
          "Scientists believe animals may be able to sense subtle changes in the environment. These could include vibrations, changes in air pressure, or shifts in the Earth's magnetic field.\n\n"
          "Some animals are more sensitive to these changes than humans. For example, certain species can detect low-frequency vibrations that humans cannot feel.\n\n"
          "However, despite many observations, there is still no solid scientific proof that animals can reliably predict earthquakes. Research on this topic is ongoing.",
      "fact":
          "The Earth's magnetic field is constantly changing, and scientists are still trying to understand how this works.",
    },
    {
      "title": "How does a seed become a tree?",
      "imageUrl": "https://wallpapercave.com/wp/wp5486895.jpg",
      "description":
          "A seed may look small and simple, but it contains everything needed to grow into a large tree. Inside the seed is an embryo along with stored nutrients.\n\n"
          "When the seed gets the right conditions—water, oxygen, and warmth—it begins a process called germination. The seed absorbs water and swells, breaking open its outer shell.\n\n"
          "The first root grows downward into the soil to absorb water and nutrients, while a small shoot begins to grow upward toward the sunlight.\n\n"
          "Over time, the plant grows leaves and starts photosynthesis, producing its own food. With years of growth, it eventually becomes a fully grown tree.",
      "fact": "The average lifespan of a tree is around 100 years.",
    },
    {
      "title": "Why is the ocean salty?",
      "imageUrl":
          "https://www.lummi.ai/api/render/image/4fb9506a-0fea-429a-81dd-6bab3fa6d912?token=eyJhbGciOiJIUzI1NiJ9.eyJpZHMiOlsiNGZiOTUwNmEtMGZlYS00MjlhLTgxZGQtNmJhYjNmYTZkOTEyIl0sInJlc29sdXRpb24iOiJtZWRpdW0iLCJyZW5kZXJTcGVjcyI6eyJlZmZlY3RzIjp7InJlZnJhbWUiOnt9fX0sInNob3VsZEF1dG9Eb3dubG9hZCI6ZmFsc2UsImp0aSI6ImJCbFBTWkwxaHNYYVJwd1Q0aVJfZCIsImlhdCI6MTc3NjkyMjExNiwiZXhwIjoxNzc2OTIyMTc2fQ.W4mHenb_ZQMp39RuyFne5UwCB3wPW2--uutueC2LNEQ",
      "description":
          "The ocean's saltiness comes from minerals that have been dissolving into water for millions of years. Rainwater plays an important role in this process.\n\n"
          "When rain falls, it slightly erodes rocks on land, picking up tiny amounts of minerals and salts. These are carried by rivers and streams into the ocean.\n\n"
          "Over time, the water evaporates from the ocean due to heat from the sun, but the salts remain behind. This causes the concentration of salt to increase.\n\n"
          "Today, the ocean is rich in dissolved salts, mainly sodium chloride, which is the same substance we use as table salt.",
      "fact":
          "The ocean covers over 70% of the Earth's surface and is the largest ecosystem on the planet.",
    },
  ];

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  void setCurrentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  void nextReading() {
    if (_currentIndex < curiosityReadingList.length - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      _currentIndex = 0; // Loop back to the first reading
      notifyListeners();
    }
  }

  void resetForNewSession() {
    _currentIndex = 0;
    notifyListeners();
  }
}
