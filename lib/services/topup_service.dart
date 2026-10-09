class TopupService {
  // Base URL icon game dari website
  static const String ICON_BASE = 'https://duniamu.my.id/icons/games/';

  // Daftar game top up lengkap (sama seperti website)
  static List<Map<String, dynamic>> getGames() {
    return [
      // MOBA
      {'id': 'mlbb', 'name': 'Mobile Legends', 'icon_file': 'mlbb.png', 'category': 'MOBA', 'color': '#1cb0f6'},
      {'id': 'aov', 'name': 'Arena of Valor', 'icon_file': 'aov.png', 'category': 'MOBA', 'color': '#7c3aed'},
      {'id': 'hok', 'name': 'Honor of Kings', 'icon_file': 'hok.png', 'category': 'MOBA', 'color': '#f59e0b'},
      {'id': 'wildrift', 'name': 'Wild Rift', 'icon_file': 'wildrift.png', 'category': 'MOBA', 'color': '#0ea5e9'},

      // Battle Royale
      {'id': 'ff', 'name': 'Free Fire', 'icon_file': 'ff.png', 'category': 'Battle Royale', 'color': '#ff4081'},
      {'id': 'pubg', 'name': 'PUBG Mobile', 'icon_file': 'pubg.png', 'category': 'Battle Royale', 'color': '#ff9800'},
      {'id': 'codm', 'name': 'COD Mobile', 'icon_file': 'codm.png', 'category': 'Battle Royale', 'color': '#4caf50'},

      // Gacha / RPG
      {'id': 'genshin', 'name': 'Genshin Impact', 'icon_file': 'genshin.png', 'category': 'Gacha/RPG', 'color': '#7c4dff'},
      {'id': 'hsr', 'name': 'Honkai Star Rail', 'icon_file': 'hsr.png', 'category': 'Gacha/RPG', 'color': '#a855f7'},
      {'id': 'arknights', 'name': 'Arknights', 'icon_file': 'arknights.svg', 'category': 'Gacha/RPG', 'color': '#06b6d4'},
      {'id': 'bluearchive', 'name': 'Blue Archive', 'icon_file': 'bluearchive.svg', 'category': 'Gacha/RPG', 'color': '#3b82f6'},
      {'id': 'nikke', 'name': 'Nikke', 'icon_file': 'nikke.svg', 'category': 'Gacha/RPG', 'color': '#ec4899'},

      // Shooter
      {'id': 'valorant', 'name': 'Valorant', 'icon_file': 'valorant.png', 'category': 'Shooter', 'color': '#ff4655'},
      {'id': 'csgo', 'name': 'CS2 / CS:GO', 'icon_file': 'csgo.png', 'category': 'Shooter', 'color': '#fbbf24'},

      // Populer
      {'id': 'roblox', 'name': 'Roblox', 'icon_file': 'roblox.png', 'category': 'Populer', 'color': '#e91e63'},
      {'id': 'minecraft', 'name': 'Minecraft', 'icon_file': 'minecraft.png', 'category': 'Populer', 'color': '#8b5cf6'},
      {'id': 'coc', 'name': 'Clash of Clans', 'icon_file': 'coc.png', 'category': 'Populer', 'color': '#f59e0b'},
      {'id': 'cr', 'name': 'Clash Royale', 'icon_file': 'cr.png', 'category': 'Populer', 'color': '#ef4444'},
      {'id': 'brawlstars', 'name': 'Brawl Stars', 'icon_file': 'brawlstars.png', 'category': 'Populer', 'color': '#8b5cf6'},

      // Voucher
      {'id': 'steam', 'name': 'Steam Wallet', 'icon_file': 'steam.png', 'category': 'Voucher', 'color': '#607d8b'},
      {'id': 'gplay', 'name': 'Google Play', 'icon_file': 'gplay.svg', 'category': 'Voucher', 'color': '#4caf50'},
      {'id': 'itunes', 'name': 'iTunes', 'icon_file': 'itunes.png', 'category': 'Voucher', 'color': '#007aff'},
      {'id': 'psn', 'name': 'PlayStation', 'icon_file': 'psn.png', 'category': 'Voucher', 'color': '#003791'},
    ];
  }

  // URL icon lengkap
  static String iconUrl(String iconFile) {
    return ICON_BASE + iconFile;
  }
}
