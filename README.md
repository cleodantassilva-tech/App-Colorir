# App Colorir

Estrutura inicial do app de desenhos para imprimir e colorir.

## Como rodar

1. Instale o Flutter SDK: https://flutter.dev
2. Coloque seus arquivos reais dentro de `assets/categorias/<categoria>/`
   (PDFs para impressão + PNGs de miniatura).
3. Atualize `lib/data/sample_data.dart` com a lista real dos seus desenhos
   (ou implemente uma leitura automática da pasta assets).
4. Rode:
   ```
   flutter pub get
   flutter run
   ```

## Impressão

A impressão usa o pacote `printing`, que abre o diálogo NATIVO do Android.
Todas as impressoras pareadas via Bluetooth ou conectadas via Wi-Fi/Wi-Fi
Direct aparecem automaticamente ali — nenhuma lógica de conexão precisa
ser implementada no app.

Para funcionar com uma impressora específica, o usuário só precisa ter
o app/plugin do fabricante instalado (Mopria, HP Print Service, Epson
Print Enabler, Canon Print Service, etc.), o que já vem em muitos
Androids ou está disponível gratuitamente na Play Store.

## Próximos passos sugeridos

- Tela de Favoritos (lista os IDs salvos pelo FavoritesService)
- Tela de Configurações (política de privacidade, sobre o app)
- Monetização (anúncios com SDK certificado para Families, ou compra única)
- Gerar automaticamente a lista de desenhos lendo a pasta de assets
  em tempo de build, para não precisar editar sample_data.dart manualmente
