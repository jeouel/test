library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_controller is
    Port (
        i_clk          : in  STD_LOGIC;
        i_reset        : in  STD_LOGIC;
        i_btn_press    : in  STD_LOGIC;  -- Signal du bouton 4
        o_note_out     : out STD_LOGIC_VECTOR(1 downto 0);  -- 2 bits pour sélectionner parmi 4 notes
        o_led_out      : out STD_LOGIC_VECTOR(3 downto 0);  -- 4 LEDs
        o_enable_audio : out STD_LOGIC   -- Signal d'activation pour l'audio
    );
end fsm_controller;

architecture Behavioral of fsm_controller is
    -- Définition des états
    type state_type is (IDLE, NOTE1, NOTE2, NOTE3, NOTE4);
    signal current_state, next_state : state_type;
    
    -- Compteur pour la durée de chaque note
    constant NOTE_DURATION : integer := 50000000;  -- ~1 seconde à 50MHz
    signal counter : integer range 0 to NOTE_DURATION;
    
begin
    -- Processus de mise à jour de l'état
    process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            current_state <= IDLE;
            counter <= 0;
        elsif rising_edge(i_clk) then
            case current_state is
                when IDLE =>
                    if i_btn_press = '1' then
                        current_state <= NOTE1;
                        counter <= 0;
                    end if;
                    
                when NOTE1 =>
                    if counter < NOTE_DURATION then
                        counter <= counter + 1;
                    else
                        current_state <= NOTE2;
                        counter <= 0;
                    end if;
                    
                when NOTE2 =>
                    if counter < NOTE_DURATION then
                        counter <= counter + 1;
                    else
                        current_state <= NOTE3;
                        counter <= 0;
                    end if;
                    
                when NOTE3 =>
                    if counter < NOTE_DURATION then
                        counter <= counter + 1;
                    else
                        current_state <= NOTE4;
                        counter <= 0;
                    end if;
                    
                when NOTE4 =>
                    if counter < NOTE_DURATION then
                        counter <= counter + 1;
                    else
                        current_state <= IDLE;
                        counter <= 0;
                    end if;
                    
                when others =>
                    current_state <= IDLE;
            end case;
        end if;
    end process;
    
    -- Processus pour la génération des sorties
    process(current_state)
    begin
        -- Valeurs par défaut
        o_note_out <= "00";
        o_led_out <= "0000";
        o_enable_audio <= '0';
        
        case current_state is
            when IDLE =>
                o_note_out <= "00";
                o_led_out <= "0000";
                o_enable_audio <= '0';
                
            when NOTE1 =>
                o_note_out <= "00";  -- Note 1
                o_led_out <= "0001";  -- LED LD0
                o_enable_audio <= '1';
                
            when NOTE2 =>
                o_note_out <= "01";  -- Note 2
                o_led_out <= "0010";  -- LED LD1
                o_enable_audio <= '1';
                
            when NOTE3 =>
                o_note_out <= "10";  -- Note 3
                o_led_out <= "0100";  -- LED LD2
                o_enable_audio <= '1';
                
            when NOTE4 =>
                o_note_out <= "11";  -- Note 4
                o_led_out <= "1000";  -- LED LD3
                o_enable_audio <= '1';
                
            when others =>
                o_note_out <= "00";
                o_led_out <= "0000";
                o_enable_audio <= '0';
        end case;
    end process;
    
end Behavioral;