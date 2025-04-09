library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity audio_codec_controller is
    Port (
        i_clk         : in  STD_LOGIC;
        i_reset       : in  STD_LOGIC;
        i_audio_in    : in  STD_LOGIC_VECTOR(23 downto 0);  -- Données audio 24 bits
        o_mclk        : out STD_LOGIC;  -- Master Clock (typiquement 12.288MHz)
        o_lrck        : out STD_LOGIC;  -- Left/Right Clock (fréquence d'échantillonnage, ex: 48kHz)
        o_sclk        : out STD_LOGIC;  -- Serial Clock (typiquement 64*fs)
        o_sdin        : out STD_LOGIC   -- Serial Data Input (données série)
    );
end audio_codec_controller;

architecture Behavioral of audio_codec_controller is
    -- Constantes pour la génération des horloges
    -- Pour 48kHz avec MCLK = 12.288MHz:
    -- MCLK_DIV = 50MHz / 12.288MHz = ~4
    -- LRCK_DIV = 12.288MHz / 48kHz = 256
    -- SCLK_DIV = LRCK_DIV / 64 = 4
    constant MCLK_DIV : integer := 4;
    constant LRCK_DIV : integer := 256;
    constant SCLK_DIV : integer := 4;
    
    -- Signaux pour les diviseurs d'horloge
    signal mclk_counter : integer range 0 to MCLK_DIV-1 := 0;
    signal lrck_counter : integer range 0 to LRCK_DIV-1 := 0;
    signal sclk_counter : integer range 0 to SCLK_DIV-1 := 0;
    
    -- Signaux internes pour les horloges
    signal mclk_int : STD_LOGIC := '0';
    signal lrck_int : STD_LOGIC := '0';
    signal sclk_int : STD_LOGIC := '0';
    
    -- Registre à décalage pour les données série
    signal shift_reg : STD_LOGIC_VECTOR(23 downto 0);
    signal bit_counter : integer range 0 to 23 := 0;
    
    -- Signal pour indiquer le début d'un nouveau cycle gauche/droite
    signal new_frame : STD_LOGIC := '0';
    
begin
    -- Générateur de MCLK (12.288MHz à partir de 50MHz)
    process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            mclk_counter <= 0;
            mclk_int <= '0';
        elsif rising_edge(i_clk) then
            if mclk_counter = MCLK_DIV-1 then
                mclk_counter <= 0;
                mclk_int <= not mclk_int;
            else
                mclk_counter <= mclk_counter + 1;
            end if;
        end if;
    end process;
    
    -- Générateur de LRCK (48kHz)
    process(mclk_int, i_reset)
    begin
        if i_reset = '1' then
            lrck_counter <= 0;
            lrck_int <= '0';
            new_frame <= '0';
        elsif rising_edge(mclk_int) then
            new_frame <= '0';  -- Par défaut, pas de nouveau cadre
            
            if lrck_counter = LRCK_DIV-1 then
                lrck_counter <= 0;
                lrck_int <= not lrck_int;
                if lrck_int = '0' then
                    new_frame <= '1';  -- Nouveau cadre au début du canal gauche
                end if;
            else
                lrck_counter <= lrck_counter + 1;
            end if;
        end if;
    end process;
    
    -- Générateur de SCLK (3.072MHz = 64fs)
    process(mclk_int, i_reset)
    begin
        if i_reset = '1' then
            sclk_counter <= 0;
            sclk_int <= '0';
        elsif rising_edge(mclk_int) then
            if sclk_counter = SCLK_DIV-1 then
                sclk_counter <= 0;
                sclk_int <= not sclk_int;
            else
                sclk_counter <= sclk_counter + 1;
            end if;
        end if;
    end process;
    
    -- Gestion des données série
    process(sclk_int, i_reset)
    begin
        if i_reset = '1' then
            shift_reg <= (others => '0');
            bit_counter <= 0;
            o_sdin <= '0';
        elsif rising_edge(sclk_int) then
            -- Chargement des nouvelles données au début d'un cadre
            if new_frame = '1' then
                shift_reg <= i_audio_in;
                bit_counter <= 0;
            elsif bit_counter < 24 then
                -- Décalage des bits un par un, MSB en premier
                o_sdin <= shift_reg(23);
                shift_reg <= shift_reg(22 downto 0) & '0';
                bit_counter <= bit_counter + 1;
            end if;
        end if;
    end process;
    
    -- Affectation des sorties
    o_mclk <= mclk_int;
    o_lrck <= lrck_int;
    o_sclk <= sclk_int;
    
end Behavioral;