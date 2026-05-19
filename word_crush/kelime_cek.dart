import 'dart:io';
import 'dart:convert';

void main() async {
  print('Kelimeler indiriliyor...');
  final url = 'https://raw.githubusercontent.com/mertemin/turkish-word-list/master/words.txt';
  final client = HttpClient();
  
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final contents = await response.transform(utf8.decoder).join();
    
    final lines = contents.split('\n');
    final out = File('assets/words.txt');
    final sink = out.openWrite();
    
    int count = 0;
    for (var line in lines) {
      var word = line.trim();
      // Sadece 3 ve daha uzun harfli kelimeleri alıyoruz
      if (word.length >= 3) {
        // Türkçe karakterleri bozmadan büyük harfe çevirme
        word = word
            .replaceAll('i', 'İ')
            .replaceAll('ğ', 'Ğ')
            .replaceAll('ü', 'Ü')
            .replaceAll('ş', 'Ş')
            .replaceAll('ö', 'Ö')
            .replaceAll('ç', 'Ç')
            .replaceAll('ı', 'I')
            .toUpperCase();
        
        sink.writeln(word);
        count++;
      }
    }
    await sink.close();
    print('Başarılı! Toplam $count kelime assets/words.txt dosyasına yazıldı.');
  } catch (e) {
    print('Hata oluştu: $e');
  } finally {
    client.close();
  }
}
