# Fichier de contraintes pour la carte Zybo Z7-10
# Horloge système
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports i_sys_clk]
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} -add [get_ports i_sys_clk]

# Reset (Bouton centrale)
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports i_sys_reset]

# Boutons
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {i_btn[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {i_btn[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {i_btn[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {i_btn[3]}]

# LEDs
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {o_led[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {o_led[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {o_led[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {o_led[3]}]

# Interface Audio
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports o_audio_mclk]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports o_audio_lrck]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports o_audio_sclk]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports o_audio_sdin]