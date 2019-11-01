#!/bin/zsh

vivaldi_style_dir=/opt/vivaldi/resources/vivaldi/style


sudo cp /opt/vivaldi/resources/vivaldi/style/common.css /opt/vivaldi/resources/vivaldi/style/common.css.bak

# sudoedit /opt/vivaldi/resources/vivaldi/style/custom.css

# sudo sed -i '1s/^/@import "custom.css";/' /opt/vivaldi/resources/vivaldi/style/common.css
sudo cp -f "$DOTFILES/vivaldi/vivaldi-custom.css" "$vivaldi_style_dir/custom.css"

grep '@import "custom.css"' "$vivaldi_style_dir/common.css" >/dev/null

if [ $? -eq 1 ]; then
  echo adding custom import
  sudo sed -i '1s/^/@import "custom.css";\n/' /opt/vivaldi/resources/vivaldi/style/common.css
fi


# sudo sed -i '1s/^/@import "custom.css";/' /opt/vivaldi/resources/vivaldi/style/common.css
