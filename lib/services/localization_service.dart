import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  String _languageCode = 'en';

  String get languageCode => _languageCode;

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'title_space_invaders': 'SPACE INVADERS',
      'btn_start_game': 'START GAME',
      'btn_statistics': 'STATISTICS',
      'btn_leaderboard': 'LEADERBOARD',
      'btn_achievements': 'ACHIEVEMENTS',
      'btn_settings': 'SETTINGS',
      'btn_campaign': 'CAMPAIGN',
      'btn_hangar': 'HANGAR',
      'menu_controls': 'CONTROLS',
      'ctrl_move': 'Move',
      'ctrl_shoot': 'Shoot',
      'ctrl_pause': 'Pause',
      'menu_tagline': 'Defend Earth!',
      'title_statistics': 'Statistics',
      'title_settings': 'Settings',
      'title_achievements': 'Achievements',
      'title_leaderboard': 'Leaderboard',
      'title_campaign': 'Campaign',
      'title_hangar': 'Hangar',
      'title_game_over': 'GAME OVER',
      'title_victory': 'VICTORY!',
      'btn_play_again': 'PLAY AGAIN',
      'btn_menu': 'MENU',
      'lbl_score': 'Score',
      'lbl_level': 'Level',
      'lbl_high_score': 'High Score',
      'leaderboard_empty': 'No scores yet. Play a game to set a new record!',
      'leaderboard_tab_all': 'All',
      'leaderboard_tab_boss_rush': 'Boss Rush',
      'powerup_multi_shot': 'MULTI-SHOT',
      'powerup_shield': 'SHIELD',
      'powerup_speed_boost': 'SPEED BOOST',
      'powerup_extra_life': 'EXTRA LIFE',
      'powerup_prefix_rush': 'RUSH ',
      'powerup_prefix_run': 'RUN ',
      'powerup_prefix_hard': 'HARD ',
      'combo_banner': 'COMBO x{x}!',
      'lbl_credits': 'Credits',
      'lbl_price': 'Price',
      'lbl_credits_earned': 'Credits earned',
      'lbl_credits_total': 'Total credits',
      'btn_upgrade': 'UPGRADE',
      'btn_maxed': 'MAXED',
      'upgrade_max_level': 'MAX LEVEL REACHED',
      'upgrade_not_enough_credits': 'Not enough credits',
      'upgrade_purchased': 'Upgrade purchased!',
      'upgrade_extraLife_name': 'Extra Lives',
      'upgrade_extraLife_desc':
          'Start each game with additional lives (up to 5 in total).',
      'upgrade_shieldStrength_name': 'Shield Strength',
      'upgrade_shieldStrength_desc':
          'Improves barrier durability and shield power-up duration.',
      'upgrade_dropChance_name': 'Drop Booster',
      'upgrade_dropChance_desc':
          'Increases chance for power-ups to drop from enemies.',
      'upgrade_startingPower_name': 'Starting Power',
      'upgrade_startingPower_desc':
          'Begin each run with temporary multi-shot and protection.',
      'campaign_locked': 'Locked',
      'campaign_available': 'Available',
      'campaign_completed': 'Completed',
      'campaign_mission_complete': 'MISSION COMPLETE!',
      'btn_next_mission': 'NEXT MISSION',
      'campaign_m1_title': 'Mission 1: First Contact',
      'campaign_m1_desc':
          'Survive the first assault: reach level 2, score 200 points and destroy 20 enemies in Classic mode.',
      'campaign_m1_intro':
          'Fleet Command: "Enemy scouts approaching Earth orbit. This is your first engagement, pilot. Hold the line and show them we are not defenceless."',
      'campaign_m2_title': 'Mission 2: Orbital Siege',
      'campaign_m2_desc':
          'Push the invaders back: reach level 4, score 600 points and destroy 60 enemies in Classic mode.',
      'campaign_m2_intro':
          'Intel: "The first wave is broken, but a larger force is forming a ring around the planet. Break the siege before they cut off our launch windows."',
      'campaign_m3_title': 'Mission 3: Endless Night',
      'campaign_m3_desc':
          'Hold the line in Survival: reach level 5, score 1000 points and destroy 80 enemies.',
      'campaign_m3_intro':
          'Ops: "We have no clear end to this attack, pilot. Your job is simple: survive as long as you can and buy us time to evacuate the colonies."',
      'campaign_m4_title': 'Mission 4: Last Stand',
      'campaign_m4_desc':
          'Survive Hardcore: reach level 3, score 800 points and destroy 50 enemies with only one life.',
      'campaign_m4_intro':
          'Commander: "This is it. No reserves, no backup, one ship. If you fall here, there is nothing between them and the surface."',
      'campaign_m5_title': 'Mission 5: Galactic Run',
      'campaign_m5_desc':
          'Conquer the rogue waves in Galactic Run: reach level 4, score 1200 points and destroy 80 enemies.',
      'campaign_m5_intro':
          'Science Division: "The enemy formation is unstable in deep space. Use the chaos of Galactic Run, pick off their command ships and end this war."',
    },
    'ru': {
      'title_space_invaders': 'SPACE INVADERS',
      'btn_start_game': 'НАЧАТЬ ИГРУ',
      'btn_statistics': 'СТАТИСТИКА',
      'btn_leaderboard': 'РЕКОРДЫ',
      'btn_achievements': 'ДОСТИЖЕНИЯ',
      'btn_settings': 'НАСТРОЙКИ',
      'btn_campaign': 'КАМПАНИЯ',
      'btn_hangar': 'АНГАР',
      'menu_controls': 'УПРАВЛЕНИЕ',
      'ctrl_move': 'Движение',
      'ctrl_shoot': 'Выстрел',
      'ctrl_pause': 'Пауза',
      'menu_tagline': 'Защити Землю!',
      'title_statistics': 'Статистика',
      'title_settings': 'Настройки',
      'title_achievements': 'Достижения',
      'title_leaderboard': 'Рекорды',
      'title_campaign': 'Кампания',
      'title_hangar': 'Ангар',
      'title_game_over': 'ИГРА ОКОНЧЕНА',
      'title_victory': 'ПОБЕДА!',
      'btn_play_again': 'СЫГРАТЬ ЕЩЁ',
      'btn_menu': 'МЕНЮ',
      'lbl_score': 'Очки',
      'lbl_level': 'Уровень',
      'lbl_high_score': 'Рекорд',
      'leaderboard_empty': 'Пока нет рекордов. Сыграйте, чтобы установить первый!',
      'leaderboard_tab_all': 'Все',
      'leaderboard_tab_boss_rush': 'Boss Rush',
      'powerup_multi_shot': 'МУЛЬТИ-ШОТ',
      'powerup_shield': 'ЩИТ',
      'powerup_speed_boost': 'СКОРОСТЬ',
      'powerup_extra_life': 'ДОП. ЖИЗНЬ',
      'powerup_prefix_rush': 'RUSH ',
      'powerup_prefix_run': 'RUN ',
      'powerup_prefix_hard': 'HARD ',
      'combo_banner': 'КОМБО x{x}!',
      'lbl_credits': 'Кредиты',
      'lbl_price': 'Цена',
      'lbl_credits_earned': 'Получено кредитов',
      'lbl_credits_total': 'Всего кредитов',
      'btn_upgrade': 'УЛУЧШИТЬ',
      'btn_maxed': 'МАКС',
      'upgrade_max_level': 'МАКС. УРОВЕНЬ',
      'upgrade_not_enough_credits': 'Недостаточно кредитов',
      'upgrade_purchased': 'Улучшение куплено!',
      'upgrade_extraLife_name': 'Доп. жизни',
      'upgrade_extraLife_desc':
          'Начинай игру с дополнительными жизнями (до 5 максимум).',
      'upgrade_shieldStrength_name': 'Прочность щита',
      'upgrade_shieldStrength_desc':
          'Усиливает барьеры и увеличивает длительность щита.',
      'upgrade_dropChance_name': 'Шанс дропа',
      'upgrade_dropChance_desc':
          'Повышает шанс выпадения усилений с врагов.',
      'upgrade_startingPower_name': 'Стартовая мощь',
      'upgrade_startingPower_desc':
          'Начинай каждую игру с временным мультишотом и защитой.',
      'campaign_locked': 'Закрыто',
      'campaign_available': 'Доступно',
      'campaign_completed': 'Выполнено',
      'campaign_mission_complete': 'МИССИЯ ВЫПОЛНЕНА!',
      'btn_next_mission': 'СЛЕД. МИССИЯ',
      'campaign_m1_title': 'Миссия 1: Первый контакт',
      'campaign_m1_desc':
          'Переживи первую атаку: достигни уровня 2, набери 200 очков и уничтожь 20 врагов в классическом режиме.',
      'campaign_m1_intro':
          'Штаб: "Вражеские разведчики выходят на орбиту Земли. Это твой первый бой, пилот. Удержи рубеж и покажи, что мы не беззащитны."',
      'campaign_m2_title': 'Миссия 2: Орбитальная осада',
      'campaign_m2_desc':
          'Отбрось захватчиков: достигни уровня 4, набери 600 очков и уничтожь 60 врагов в классическом режиме.',
      'campaign_m2_intro':
          'Разведка: "Первую волну мы отбили, но крупные силы формируют кольцо вокруг планеты. Прорви осаду, пока они не перекрыли окна запуска."',
      'campaign_m3_title': 'Миссия 3: Бесконечная ночь',
      'campaign_m3_desc':
          'Удержи линию в режиме Выживание: достигни уровня 5, набери 1000 очков и уничтожь 80 врагов.',
      'campaign_m3_intro':
          'Оперативный центр: "Мы не видим конца этой атаке. Твоя задача проста: живи как можно дольше и дай нам время эвакуировать колонии."',
      'campaign_m4_title': 'Миссия 4: Последний рубеж',
      'campaign_m4_desc':
          'Выживи в Харкорде: достигни уровня 3, набери 800 очков и уничтожь 50 врагов, имея одну жизнь.',
      'campaign_m4_intro':
          'Командир: "Это всё. Без резервов, без подмоги, один корабль. Если ты падёшь здесь, между ними и поверхностью больше никого не останется."',
      'campaign_m5_title': 'Миссия 5: Galactic Run',
      'campaign_m5_desc':
          'Покори рогалик-волны в Galactic Run: достигни уровня 4, набери 1200 очков и уничтожь 80 врагов.',
      'campaign_m5_intro':
          'Научный отдел: "Их формации нестабильны в глубоком космосе. Используй хаос режима Galactic Run, выбей их командные корабли и закончи эту войну."',
    },
  };

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _languageCode = prefs.getString('language_code') ?? 'en';
    } catch (_) {
      _languageCode = 'en';
    }
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', code);
    } catch (_) {}
  }

  String t(String key) {
    final lang = _values[_languageCode] ?? _values['en']!;
    return lang[key] ?? _values['en']![key] ?? key;
  }
}
