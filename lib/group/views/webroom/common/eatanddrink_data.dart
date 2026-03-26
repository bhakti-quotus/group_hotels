class Restaurant {
  final String id;
  final String name;
  final String tagline;
  final String timing;
  final String image;
  final String description;
  final String philosophy;
  final String openingTimes;
  final List<String> meals;
  final bool requestTable;

  const Restaurant({
    required this.id,
    required this.name,
    required this.tagline,
    required this.timing,
    required this.image,
    required this.description,
    required this.philosophy,
    required this.openingTimes,
    required this.meals,
    required this.requestTable,
  });
}

class EatAndDrinkData {
  static const List<Restaurant> restaurants = [
    Restaurant(
      id: 'tao',
      name: 'Tao',
      tagline: 'Cuisine Quo Wim fusion cuisine',
      timing: 'Each and every evening from 07:30 p.m.',
      image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLYpLLPbS4D1TYWwSSY6egwViYfiKCBJ15zQ&s',
      description:
          'TAO Restaurant is our signature, offering cuisine with influences from both East and West. One side of the dining room is opened up facing the sea, providing the contrasting sights and sounds of the Caribbean and the starry sky.',
      philosophy:
          'Tao is dedicated to a nutritious and delicious dining experience which contributes to a balanced and healthier lifestyle. The cuisine is complemented with outstanding service in a harmonious and comfortable environment.',
      openingTimes:
          'TAO is open each and every evening from 07:30 p.m. *Reservations are essential.',
      meals: ['Dinner'],
      requestTable: true,
    ),
    Restaurant(
      id: 'caribue',
      name: 'Caribue',
      tagline: 'International cuisines',
      timing: 'Breakfast: 07:00 a.m. - 10:30 a.m.',
      image: 'https://img.freepik.com/free-photo/restaurant-interior_1127-3394.jpg?semt=ais_hybrid&w=740&q=80',
      description:
          'Caribue serves a wide variety of international cuisines in a relaxed and welcoming atmosphere. Perfect for a leisurely breakfast to start your day.',
      philosophy:
          'Bringing the world\'s flavours to Saint Lucia, Caribue celebrates diversity through food.',
      openingTimes: 'Breakfast: 07:00 a.m. - 10:30 a.m.',
      meals: ['Breakfast'],
      requestTable: true,
    ),
    Restaurant(
      id: 'caribue_windows',
      name: 'Caribue Windows',
      tagline: 'Fine Dine Plant Testing Menu',
      timing: '5 nights a week, 07:30 p.m. - 09:00 p.m.',
      image: 'https://images.travelandleisureasia.com/wp-content/uploads/sites/2/2025/05/02141004/aesthetic-rest-hero.jpeg?tr=w-1200,q-60',
      description:
          'Caribue Windows offers an exclusive fine dining plant-based tasting menu experience. Available five nights a week for a curated culinary journey.',
      philosophy:
          'A plant-forward approach to fine dining, showcasing the richness of nature\'s produce in every course.',
      openingTimes: '5 nights a week, 07:30 p.m. - 09:00 p.m.',
      meals: ['Dinner'],
      requestTable: true,
    ),
  ];

  static const List<MenuItem> menuItems = [
    MenuItem(category: 'Starters', name: 'Coconut Ceviche', price: '\$14'),
    MenuItem(category: 'Starters', name: 'Spiced Pumpkin Soup', price: '\$10'),
    MenuItem(category: 'Mains', name: 'Grilled Sea Bass', price: '\$32'),
    MenuItem(category: 'Mains', name: 'Caribbean Jerk Chicken', price: '\$28'),
    MenuItem(category: 'Mains', name: 'Plantain & Bean Bowl', price: '\$22'),
    MenuItem(category: 'Desserts', name: 'Passion Fruit Panna Cotta', price: '\$12'),
    MenuItem(category: 'Desserts', name: 'Dark Chocolate Fondant', price: '\$14'),
    MenuItem(category: 'Beverages', name: 'Fresh Coconut Water', price: '\$6'),
    MenuItem(category: 'Beverages', name: 'Tropical Juice Blend', price: '\$8'),
  ];
}

class MenuItem {
  final String category;
  final String name;
  final String price;

  const MenuItem({
    required this.category,
    required this.name,
    required this.price,
  });
}