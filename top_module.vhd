library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module is
    Port (
        -- Signaux d'horloge et reset
        i_sys_clk      : in  STD_LOGIC;
        i_sys_reset    : in  STD_LOGIC;
        
        -- Interface boutons
        i_btn          : in  STD_LOGIC_VECTOR(3 downto 0);  -- Boutons de la carte
        
        -- Interface LEDs
        o_led          : out STD_LOGIC_VECTOR(3 downto 0);  -- LEDs de la carte
        
        -- Interface audio
        o_audio_mclk   : out STD_LOGIC;  -- Master clock pour le codec audio
        o_audio_lrck   : out STD_LOGIC;  -- Left/Right clock
        o_audio_sclk   : out STD_LOGIC;  -- Serial clock
        o_audio_sdin   : out STD_LOGIC   -- Serial data input pour le DAC
    );
end top_module;

architecture Behavioral of top_module is
    -- Déclaration des composants
    component fsm_controller
        Port (
            i_clk          : in  STD_LOGIC;
            i_reset        : in  STD_LOGIC;
            i_btn_press    : in  STD_LOGIC;
            o_note_out     : out STD_LOGIC_VECTOR(1 downto 0);
            o_led_out      : out STD_LOGIC_VECTOR(3 downto 0);
            o_enable_audio : out STD_LOGIC
        );
    end component;
    
    component button_debounce
        Port (
            i_clk         : in  STD_LOGIC;
            i_reset       : in  STD_LOGIC;
            i_button_in   : in  STD_LOGIC;
            o_button_out  : out STD_LOGIC
        );
    end component;
    
    component sound_generator
        Port (
            i_clk         : in  STD_LOGIC;
            i_reset       : in  STD_LOGIC;
            i_enable      : in  STD_LOGIC;
            i_note_sel    : in  STD_LOGIC_VECTOR(1 downto 0);
            o_audio_out   : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;
    
    component audio_codec_controller
        Port (
            i_clk         : in  STD_LOGIC;
            i_reset       : in  STD_LOGIC;
            i_audio_in    : in  STD_LOGIC_VECTOR(23 downto 0);
            o_mclk        : out STD_LOGIC;
            o_lrck        : out STD_LOGIC;
            o_sclk        : out STD_LOGIC;
            o_sdin        : out STD_LOGIC
        );
    end component;
    
    -- Signaux internes
    signal btn4_debounced : STD_LOGIC;
    signal note_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal enable_audio : STD_LOGIC;
    signal audio_data : STD_LOGIC_VECTOR(23 downto 0);
    
begin
    -- Instanciation du module d'anti-rebond pour le bouton 4 (normalement BTN[3])
    button_debounce_inst: button_debounce
        port map (
            i_clk => i_sys_clk,
            i_reset => i_sys_reset,
            i_button_in => i_btn(3),
            o_button_out => btn4_debounced
        );
    
    -- Instanciation du contrôleur FSM
    fsm_controller_inst: fsm_controller
        port map (
            i_clk => i_sys_clk,
            i_reset => i_sys_reset,
            i_btn_press => btn4_debounced,
            o_note_out => note_sel,
            o_led_out => o_led,
            o_enable_audio => enable_audio
        );
    
    -- Instanciation du générateur de son
    sound_generator_inst: sound_generator
        port map (
            i_clk => i_sys_clk,
            i_reset => i_sys_reset,
            i_enable => enable_audio,
            i_note_sel => note_sel,
            o_audio_out => audio_data
        );
    
    -- Instanciation du contrôleur de codec audio
    audio_codec_controller_inst: audio_codec_controller
        port map (
            i_clk => i_sys_clk,
            i_reset => i_sys_reset,
            i_audio_in => audio_data,
            o_mclk => o_audio_mclk,
            o_lrck => o_audio_lrck,
            o_sclk => o_audio_sclk,
            o_sdin => o_audio_sdin
        );
    
end Behavioral;