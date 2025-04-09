library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sound_generator is
    Port (
        i_clk         : in  STD_LOGIC;
        i_reset       : in  STD_LOGIC;
        i_enable      : in  STD_LOGIC;  -- Activation du générateur de son
        i_note_sel    : in  STD_LOGIC_VECTOR(1 downto 0);  -- Sélection de la note
        o_audio_out   : out STD_LOGIC_VECTOR(23 downto 0)  -- Sortie audio 24 bits
    );
end sound_generator;

architecture Behavioral of sound_generator is
    -- Constantes pour les fréquences des notes (à 50MHz)
    -- Ces valeurs représentent les incréments pour un accumulateur de phase
    -- Do4 (~262Hz): 50MHz / 262Hz * 2^24 = 7982
    -- Mi4 (~330Hz): 50MHz / 330Hz * 2^24 = 6339
    -- Sol4 (~392Hz): 50MHz / 392Hz * 2^24 = 5334
    -- Do5 (~523Hz): 50MHz / 523Hz * 2^24 = 3991
    constant NOTE_C4 : unsigned(31 downto 0) := to_unsigned(7982, 32);
    constant NOTE_E4 : unsigned(31 downto 0) := to_unsigned(6339, 32);
    constant NOTE_G4 : unsigned(31 downto 0) := to_unsigned(5334, 32);
    constant NOTE_C5 : unsigned(31 downto 0) := to_unsigned(3991, 32);
    
    -- Signaux internes
    signal phase_acc : unsigned(31 downto 0) := (others => '0');  -- Accumulateur de phase
    signal phase_inc : unsigned(31 downto 0) := (others => '0');  -- Incrément de phase
    signal audio_sample : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    
begin
    -- Sélection de la fréquence en fonction de la note
    process(i_note_sel)
    begin
        case i_note_sel is
            when "00" => phase_inc <= NOTE_C4;  -- Note 1: Do4
            when "01" => phase_inc <= NOTE_E4;  -- Note 2: Mi4
            when "10" => phase_inc <= NOTE_G4;  -- Note 3: Sol4
            when "11" => phase_inc <= NOTE_C5;  -- Note 4: Do5
            when others => phase_inc <= NOTE_C4;
        end case;
    end process;
    
    -- Génération de l'onde
    process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            phase_acc <= (others => '0');
        elsif rising_edge(i_clk) then
            if i_enable = '1' then
                -- Incrémentation de l'accumulateur de phase
                phase_acc <= phase_acc + phase_inc;
            else
                phase_acc <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Génération de l'onde sinusoïdale (ici simplifiée par une onde carrée)
    -- En pratique, on utiliserait une ROM avec une table de sinus
    process(phase_acc)
    begin
        if phase_acc(31) = '1' then
            audio_sample <= x"7FFFFF";  -- Valeur positive maximum (pour 24 bits signés)
        else
            audio_sample <= x"800000";  -- Valeur négative maximum (pour 24 bits signés)
        end if;
    end process;
    
    -- Affectation de sortie
    o_audio_out <= audio_sample when i_enable = '1' else x"000000";
    
end Behavioral;