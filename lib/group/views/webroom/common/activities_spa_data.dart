// activities_spa_data.dart

// ─── Category & subcategory master list ──────────────────────────────────────

const List<String> activitiesCategories = [
  'Water Sports',
  'Fitness',
  'Spa & Beauty',
  'Outdoor',
  'Classes',
];

const Map<String, List<String>> activitiesSubcategories = {
  'Water Sports': ['Swimming', 'Snorkeling', 'Kayaking', 'Surfing'],
  'Fitness': ['Gym', 'Personal Training', 'CrossFit', 'Pilates'],
  'Spa & Beauty': ['Massage', 'Facial', 'Body Treatment', 'Nail Care'],
  'Outdoor': ['Hiking', 'Cycling', 'Rock Climbing', 'Beach Volleyball'],
  'Classes': ['Yoga', 'Zumba', 'Meditation', 'Dance'],
};

// ─── Items ────────────────────────────────────────────────────────────────────

final List<Map<String, dynamic>> activitiesSpaItems = [
  // ── Water Sports ──────────────────────────────────────────────────────────
  {
    'title': 'Snorkeling Adventure',
    'subtitle': 'Water Sports · Snorkeling',
    'category': 'Water Sports',
    'subcategory': 'Snorkeling',
    'duration': '2 hrs',
    'price': '\$45 / person',
    'priceLabel': 'Popular',
    'images': [
      'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
      'https://images.unsplash.com/photo-1582967788606-a171c1080cb0?w=800',
      'https://images.unsplash.com/photo-1559827291-72ee739d0d9a?w=800',
    ],
    'description':
        'Dive into crystal-clear waters and explore vibrant coral reefs teeming with tropical fish. Our expert guides will lead you to the best snorkeling spots and ensure your safety throughout the experience. Equipment is provided for all skill levels.',
    'options':
        'Morning session (8:00 AM), Afternoon session (2:00 PM). Group size: max 12 participants. Equipment rental included.',
    'needToKnow':
        'Basic swimming ability required. Children under 10 must be accompanied by an adult. Reef-safe sunscreen only — provided on-site.',
    'benefits': [
      'Guided by certified marine naturalists',
      'All snorkeling equipment included',
      'Underwater photography available',
      'Suitable for beginners and experienced snorkelers',
      'Post-session freshwater shower available',
    ],
  },
  {
    'title': 'Kayaking Tour',
    'subtitle': 'Water Sports · Kayaking',
    'category': 'Water Sports',
    'subcategory': 'Kayaking',
    'duration': '3 hrs',
    'price': '\$60 / person',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1530866495561-507c9faab2ed?w=800',
      'https://images.unsplash.com/photo-1472745942893-4b9f730c7668?w=800',
    ],
    'description':
        'Paddle through serene mangroves and hidden lagoons on this guided kayaking tour. Discover the natural wonders of the coastline while our experienced guides share fascinating facts about local ecosystems and wildlife.',
    'options':
        'Single kayak or tandem kayak. Sunrise tour (6:30 AM) or Sunset tour (5:00 PM). Life jackets and paddles provided.',
    'needToKnow':
        'No prior kayaking experience needed. Minimum age 8 years. Wear quick-dry clothing. Not recommended for guests with back injuries.',
    'benefits': [
      'Explore hidden coves and mangroves',
      'Professional safety briefing included',
      'Waterproof dry bags provided',
      'Small groups for personalised experience',
      'Wildlife spotting opportunities',
    ],
  },
  {
    'title': 'Surf Lessons',
    'subtitle': 'Water Sports · Surfing',
    'category': 'Water Sports',
    'subcategory': 'Surfing',
    'duration': '90 min',
    'price': '\$75 / person',
    'priceLabel': 'Bestseller',
    'images': [
      'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=800',
      'https://images.unsplash.com/photo-1455264745730-cb3b76250de8?w=800',
      'https://images.unsplash.com/photo-1531722569936-825d4ecea6cd?w=800',
    ],
    'description':
        'Catch your first wave or refine your technique with our certified surf instructors. Sessions are tailored to your ability level, from complete beginners learning to stand up, to intermediate surfers working on turns and style.',
    'options':
        'Beginner / Intermediate / Advanced. Morning (7:00 AM) or Afternoon (3:00 PM). Surfboard and rash guard included.',
    'needToKnow':
        'Minimum age 10 years. Ability to swim 50 m required. Ocean conditions may affect availability. Book 24 hrs in advance.',
    'benefits': [
      'ISA-certified instructors',
      'Surfboard and rash guard provided',
      'Video analysis on request',
      'Max 4 students per instructor',
      'Post-lesson debriefing session',
    ],
  },
  {
    'title': 'Pool Swimming Session',
    'subtitle': 'Water Sports · Swimming',
    'category': 'Water Sports',
    'subcategory': 'Swimming',
    'duration': '60 min',
    'price': 'Complimentary',
    'priceLabel': 'Free',
    'images': [
      'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=800',
      'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=800',
    ],
    'description':
        'Enjoy the resort\'s Olympic-length heated pool, open exclusively to guests. Lap lanes are available every morning, with open swimming throughout the day. Towels, sunbeds and poolside refreshments are all included.',
    'options':
        'Lap swimming (6:00 AM – 8:00 AM), Open swimming (8:00 AM – 8:00 PM). Adult-only hours: 6:00 AM – 9:00 AM.',
    'needToKnow':
        'Swimwear must be worn at all times. No diving in shallow end. Children under 12 must be supervised.',
    'benefits': [
      'Heated to 28 °C year-round',
      'Olympic-length 50 m pool',
      'Towels and sunbeds complimentary',
      'Poolside bar & snack service',
      'Lifeguard on duty at all times',
    ],
  },

  // ── Fitness ───────────────────────────────────────────────────────────────
  {
    'title': 'Personal Training Session',
    'subtitle': 'Fitness · Personal Training',
    'category': 'Fitness',
    'subcategory': 'Personal Training',
    'duration': '60 min',
    'price': '\$90 / session',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
      'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800',
    ],
    'description':
        'Work one-on-one with a certified personal trainer to build a customised programme that aligns with your goals, whether that\'s weight loss, muscle gain, functional fitness or sports performance. All sessions begin with a fitness assessment.',
    'options':
        'Single session or 5-session package (save 15%). Strength & Conditioning, HIIT, Mobility, or Sport-Specific. Available 6:00 AM – 9:00 PM.',
    'needToKnow':
        'Arrive 10 minutes early for health screening. Suitable for all fitness levels. Bring a water bottle and towel.',
    'benefits': [
      'Customised training plan',
      'Pre-session health & fitness assessment',
      'Progress tracking across sessions',
      'Nutritional guidance included',
      'Access to full gym equipment',
    ],
  },
  {
    'title': 'CrossFit Class',
    'subtitle': 'Fitness · CrossFit',
    'category': 'Fitness',
    'subcategory': 'CrossFit',
    'duration': '45 min',
    'price': '\$25 / class',
    'priceLabel': 'High Energy',
    'images': [
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=800',
      'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?w=800',
    ],
    'description':
        'Push your limits in our high-intensity CrossFit class, featuring constantly varied functional movements performed at high intensity. Each WOD (Workout of the Day) is scalable, making it accessible for beginners while still challenging veterans.',
    'options':
        'Morning WOD (7:00 AM), Lunchtime WOD (12:30 PM), Evening WOD (6:00 PM). All equipment provided.',
    'needToKnow':
        'Minimum age 16 years. Inform coach of any injuries before class. Closed-toe athletic shoes required.',
    'benefits': [
      'Scalable for all fitness levels',
      'Community-driven atmosphere',
      'Improves strength, speed and endurance',
      'Coach-led with personalised modifications',
      'Complimentary protein shake post-class',
    ],
  },
  {
    'title': 'Pilates Reformer',
    'subtitle': 'Fitness · Pilates',
    'category': 'Fitness',
    'subcategory': 'Pilates',
    'duration': '50 min',
    'price': '\$55 / session',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
    ],
    'description':
        'Strengthen and lengthen through guided reformer Pilates, ideal for improving core stability, posture and flexibility. Sessions are available as private or semi-private, allowing the instructor to focus on your specific movement patterns.',
    'options':
        'Private (1 person) or semi-private (2 people). Beginner, Intermediate or Advanced. Morning and evening slots available.',
    'needToKnow':
        'Grip socks required (available for purchase at reception). Not recommended during first trimester of pregnancy. Arrive 5 min early.',
    'benefits': [
      'Improves core strength and stability',
      'Reduces back pain and tension',
      'Enhances flexibility and posture',
      'Low-impact — suitable post-injury',
      'Equipment and mat provided',
    ],
  },
  {
    'title': 'State-of-the-Art Gym',
    'subtitle': 'Fitness · Gym',
    'category': 'Fitness',
    'subcategory': 'Gym',
    'duration': 'Unlimited access',
    'price': 'Complimentary',
    'priceLabel': 'Free',
    'images': [
      'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800',
      'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=800',
    ],
    'description':
        'Our 800 m² fully equipped gym features the latest Technogym cardio machines, free weights from 1–60 kg, cable stations, power racks and a dedicated stretching zone. Air-conditioned with ocean views.',
    'options':
        'Open daily 5:30 AM – 11:00 PM. Towel service, lockers and complimentary water provided. Personal trainers on-site 6 AM – 9 PM.',
    'needToKnow':
        'Appropriate gym attire and closed-toe shoes required. Minimum age 16 (or 14 with parental consent). Wipe down equipment after use.',
    'benefits': [
      'Latest Technogym cardio & strength equipment',
      'Ocean views from all treadmills',
      'Free towel service & locker',
      'Complimentary workout programmes available',
      'Personal trainers available on request',
    ],
  },

  // ── Spa & Beauty ─────────────────────────────────────────────────────────
  {
    'title': 'Signature Hot Stone Massage',
    'subtitle': 'Spa & Beauty · Massage',
    'category': 'Spa & Beauty',
    'subcategory': 'Massage',
    'duration': '90 min',
    'price': '\$130 / person',
    'priceLabel': 'Signature',
    'images': [
      'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800',
      'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?w=800',
      'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=800',
    ],
    'description':
        'Surrender to deep relaxation as smooth, heated basalt stones are placed along your body\'s energy centres and glided over tense muscles. The warmth penetrates deeply to release knots, stimulate circulation and restore balance.',
    'options':
        'Single or couples treatment. Aromatherapy upgrade available (+\$20). Morning, afternoon or evening appointments.',
    'needToKnow':
        'Avoid heavy meals 2 hours before. Not suitable for guests with cardiovascular conditions, diabetes or skin sensitivities. Disclose any medical conditions at booking.',
    'benefits': [
      'Relieves chronic muscle tension',
      'Improves blood circulation',
      'Reduces stress and anxiety',
      'Promotes deep, restful sleep',
      'Post-treatment herbal tea included',
    ],
  },
  {
    'title': 'Luxury Facial Treatment',
    'subtitle': 'Spa & Beauty · Facial',
    'category': 'Spa & Beauty',
    'subcategory': 'Facial',
    'duration': '60 min',
    'price': '\$95 / person',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=800',
      'https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?w=800',
    ],
    'description':
        'A bespoke facial tailored to your skin type and concerns. Your therapist begins with a detailed skin analysis before selecting from our range of ESPA products. The treatment combines deep cleansing, exfoliation, steam, extractions and a customised masque.',
    'options':
        'Express (30 min / \$50), Classic (60 min), Deluxe with LED therapy (90 min / \$140). Anti-ageing and brightening variants available.',
    'needToKnow':
        'Discontinue retinol 5 days before. Inform therapist of active breakouts or recent cosmetic procedures. Avoid sun exposure 24 hrs after.',
    'benefits': [
      'Personalised skin analysis and consultation',
      'Deep pore cleansing and hydration',
      'Uses premium ESPA skincare products',
      'Visible radiance after single session',
      'Take-home skincare recommendations',
    ],
  },
  {
    'title': 'Tropical Body Wrap',
    'subtitle': 'Spa & Beauty · Body Treatment',
    'category': 'Spa & Beauty',
    'subcategory': 'Body Treatment',
    'duration': '75 min',
    'price': '\$110 / person',
    'priceLabel': 'New',
    'images': [
      'https://images.unsplash.com/photo-1507652313519-d4e9174996dd?w=800',
      'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
    ],
    'description':
        'Indulge in this deeply nourishing body treatment combining a coconut-sugar exfoliation, followed by a warm papaya-enzyme body wrap to detoxify and soften skin. Finished with a hydrating coconut oil application that leaves skin glowing.',
    'options':
        'Detoxifying Seaweed Wrap or Hydrating Coconut Wrap. Can be paired with a massage for a full-day package.',
    'needToKnow':
        'Shower facilities provided on-site. Avoid shaving 24 hours prior. Not recommended during pregnancy. Loose, comfortable clothing advised for after.',
    'benefits': [
      'Deep exfoliation removes dead skin cells',
      'Detoxifies and firms skin',
      'Deeply hydrating and nourishing',
      'Improves skin texture and tone',
      'Complimentary robe and slippers provided',
    ],
  },
  {
    'title': 'Luxury Nail Studio',
    'subtitle': 'Spa & Beauty · Nail Care',
    'category': 'Spa & Beauty',
    'subcategory': 'Nail Care',
    'duration': '60 min',
    'price': '\$55 / person',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800',
      'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800',
    ],
    'description':
        'Pamper yourself in our bright, modern nail studio offering manicures, pedicures and nail art. Our nail technicians use only non-toxic, cruelty-free polishes and practise impeccable hygiene with sterilised tools for every client.',
    'options':
        'Classic Manicure, Gel Manicure, Classic Pedicure, Spa Pedicure, Nail Art add-on (+\$15). Walk-ins welcome, appointments preferred.',
    'needToKnow':
        'Gel removal service available (\$10). Bring open-toe sandals for pedicures. Appointments available 9:00 AM – 7:00 PM daily.',
    'benefits': [
      'Non-toxic, cruelty-free polish range',
      'Sterilised tools for every client',
      'Hot stone foot massage included in spa pedicure',
      'Wide range of OPI & Essie shades',
      'Complimentary nail strengthening treatment',
    ],
  },

  // ── Outdoor ───────────────────────────────────────────────────────────────
  {
    'title': 'Guided Nature Hike',
    'subtitle': 'Outdoor · Hiking',
    'category': 'Outdoor',
    'subcategory': 'Hiking',
    'duration': '3 hrs',
    'price': '\$35 / person',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
      'https://images.unsplash.com/photo-1501554728187-ce583db33af7?w=800',
    ],
    'description':
        'Explore the lush trails surrounding the resort with our knowledgeable local guides. The route winds through tropical forest, past cascading waterfalls and up to a panoramic ridge with sweeping ocean views. Suitable for moderate fitness levels.',
    'options':
        'Easy trail (2 hrs / \$25), Moderate trail (3 hrs / \$35), Challenging summit trail (5 hrs / \$55). Sunrise hike available on weekends.',
    'needToKnow':
        'Sturdy closed-toe shoes required. Water and snacks provided. Sunscreen and insect repellent recommended. Min. age 8 years.',
    'benefits': [
      'Led by certified naturalist guides',
      'Water and energy bars provided',
      'Wildlife and birdwatching opportunities',
      'Photography tips and stops included',
      'Post-hike stretch session offered',
    ],
  },
  {
    'title': 'Coastal Cycling Tour',
    'subtitle': 'Outdoor · Cycling',
    'category': 'Outdoor',
    'subcategory': 'Cycling',
    'duration': '2 hrs',
    'price': '\$30 / person',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1541625602330-2277a4c46182?w=800',
      'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
    ],
    'description':
        'Pedal along scenic coastal paths and through charming local villages on our guided cycling tour. Electric-assist bikes are available for those who want to enjoy the scenery without the effort. Helmets and safety briefing always included.',
    'options':
        'Standard bicycle or e-bike (+\$10). Morning (7:30 AM) or Late Afternoon (4:30 PM) tour. Helmet and lock provided.',
    'needToKnow':
        'Minimum age 12 years. Ability to ride a bicycle required. Route is mostly flat with one gentle incline.',
    'benefits': [
      'Scenic coastal and village route',
      'E-bike option available',
      'Helmet and safety gear included',
      'Local cultural highlights en route',
      'Photo stops at best viewpoints',
    ],
  },
  {
    'title': 'Beach Volleyball',
    'subtitle': 'Outdoor · Beach Volleyball',
    'category': 'Outdoor',
    'subcategory': 'Beach Volleyball',
    'duration': '60 min',
    'price': 'Complimentary',
    'priceLabel': 'Free',
    'images': [
      'https://images.unsplash.com/photo-1612872087720-bb876e2e67d1?w=800',
      'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=800',
    ],
    'description':
        'Join an informal beach volleyball game on the resort\'s dedicated sand court. Whether you\'re a seasoned player or a first-timer, our activities team organises fun matches throughout the day. Organised tournaments run every Friday evening.',
    'options':
        'Drop-in games throughout the day. Organised tournaments: Fridays 5:00 PM. Equipment provided at the activities desk.',
    'needToKnow':
        'No booking required for casual play. Tournament registration closes Thursday 8:00 PM. Barefoot or sand socks recommended.',
    'benefits': [
      'Fun for all levels',
      'Organised tournaments with prizes',
      'Great way to meet fellow guests',
      'All equipment provided',
      'Activities team on-hand to referee',
    ],
  },
  {
    'title': 'Rock Climbing Wall',
    'subtitle': 'Outdoor · Rock Climbing',
    'category': 'Outdoor',
    'subcategory': 'Rock Climbing',
    'duration': '60 min',
    'price': '\$20 / session',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=800',
      'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800',
    ],
    'description':
        'Test your strength and problem-solving skills on our 10-metre outdoor climbing wall, featuring routes graded from beginner to advanced. Our trained belay staff ensure complete safety so you can focus on the climb.',
    'options':
        'Open sessions (self-guided with supervision) or Guided intro lesson (+\$15). Harness and shoes provided. Open 8:00 AM – 6:00 PM.',
    'needToKnow':
        'Minimum age 7 years (supervised). Closed-toe shoes required (climbing shoes provided). Not recommended for guests with shoulder or wrist injuries.',
    'benefits': [
      'Routes for all ability levels',
      'Certified belay staff on site',
      'Harness and climbing shoes provided',
      'Improves strength and coordination',
      'Team-building options available',
    ],
  },

  // ── Classes ───────────────────────────────────────────────────────────────
  {
    'title': 'Sunrise Yoga',
    'subtitle': 'Classes · Yoga',
    'category': 'Classes',
    'subcategory': 'Yoga',
    'duration': '60 min',
    'price': '\$20 / class',
    'priceLabel': 'Daily',
    'images': [
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
      'https://images.unsplash.com/photo-1588286840104-8957b019727f?w=800',
      'https://images.unsplash.com/photo-1545389336-cf090694435e?w=800',
    ],
    'description':
        'Begin your day with an invigorating sunrise yoga class on the ocean-view deck. Led by our resident yoga teacher, each session weaves together breathwork, sun salutations and mindful movement to energise body and mind for the day ahead.',
    'options':
        'Hatha (all levels), Vinyasa (intermediate), Yin (all levels, evenings). Mats, blocks and straps provided. Daily at 6:30 AM.',
    'needToKnow':
        'No prior yoga experience required for Hatha and Yin classes. Vinyasa suited to those with basic yoga familiarity. Arrive 5 min early. Barefoot.',
    'benefits': [
      'Ocean-view open-air deck setting',
      'All props provided',
      'Suitable for all fitness levels',
      'Improves flexibility and mindfulness',
      'Complimentary herbal tea after class',
    ],
  },
  {
    'title': 'Zumba Fitness Party',
    'subtitle': 'Classes · Zumba',
    'category': 'Classes',
    'subcategory': 'Zumba',
    'duration': '45 min',
    'price': '\$15 / class',
    'priceLabel': 'Fun!',
    'images': [
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
    ],
    'description':
        'Dance your way to fitness in this high-energy Zumba class set to infectious Latin rhythms and world music. No dance experience necessary — just bring your energy and a big smile. Classes are held on the beach terrace for a fun, tropical feel.',
    'options':
        'Monday, Wednesday, Friday at 5:30 PM. Saturday at 10:00 AM (family session, all ages welcome). No equipment needed.',
    'needToKnow':
        'Wear comfortable, lightweight workout attire. Supportive trainers recommended. Stay hydrated — water station available.',
    'benefits': [
      'Burns up to 600 calories per session',
      'No dance experience required',
      'Fun, social group atmosphere',
      'Improves coordination and rhythm',
      'Beach terrace open-air setting',
    ],
  },
  {
    'title': 'Guided Meditation',
    'subtitle': 'Classes · Meditation',
    'category': 'Classes',
    'subcategory': 'Meditation',
    'duration': '30 min',
    'price': '\$15 / session',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1508672019048-805c876b67e2?w=800',
      'https://images.unsplash.com/photo-1593811167562-9cef47bfc4d7?w=800',
    ],
    'description':
        'Find stillness and clarity in a guided meditation session by the ocean. Our mindfulness facilitator leads each session through breath-awareness, body-scan and visualisation techniques, making the practice accessible even for complete beginners.',
    'options':
        'Daily at 7:00 AM and 7:30 PM. Group (up to 10) or private one-on-one session (+\$25). Cushions and mats provided.',
    'needToKnow':
        'Arrive 5 minutes early to settle in. Wear comfortable, loose-fitting clothing. Sessions take place rain or shine (indoor option available).',
    'benefits': [
      'Reduces stress and mental fatigue',
      'Improves focus and emotional balance',
      'Suitable for complete beginners',
      'Ocean soundscape environment',
      'Optional post-session journaling prompts',
    ],
  },
  {
    'title': 'Latin Dance Class',
    'subtitle': 'Classes · Dance',
    'category': 'Classes',
    'subcategory': 'Dance',
    'duration': '60 min',
    'price': '\$25 / class',
    'priceLabel': null,
    'images': [
      'https://images.unsplash.com/photo-1504609813442-a8924e83f76e?w=800',
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800',
    ],
    'description':
        'Learn the fundamentals of salsa, bachata or merengue from our passionate dance instructors. Classes are structured, progressive and above all joyful — couples and solo participants both welcome. A perfect evening activity to connect and let loose.',
    'options':
        'Salsa, Bachata or Merengue. Beginner (Tue & Thu at 7:00 PM), Intermediate (Sat at 7:00 PM). Solo or couples.',
    'needToKnow':
        'Comfortable, flexible shoes recommended. No partner required. Minimum age 14 years. Class size limited to 16 participants.',
    'benefits': [
      'Learn salsa, bachata or merengue',
      'Fun, social atmosphere',
      'Improves coordination and confidence',
      'Solo and couples welcome',
      'Performance night every two weeks',
    ],
  },
];