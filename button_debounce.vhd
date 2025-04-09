library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity button_debounce is
    Port (
        i_clk         : in  STD_LOGIC;
        i_reset       : in  STD_LOGIC;
        i_button_in   : in  STD_LOGIC;  -- Entrée brute du bouton
        o_button_out  : out STD_LOGIC   -- Sortie stabilisée du bouton
    );
end button_debounce;

architecture Behavioral of button_debounce is
    -- Constantes
    constant DEBOUNCE_TIME : integer := 500000;  -- 10ms à 50MHz
    
    -- Signaux internes
    signal count : integer range 0 to DEBOUNCE_TIME := 0;
    signal button_state : STD_LOGIC := '0';
    signal button_sync : STD_LOGIC_VECTOR(1 downto 0) := "00";
    
begin
    -- Synchronisation d'entrée pour éviter les métastabilités
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            button_sync(0) <= i_button_in;
            button_sync(1) <= button_sync(0);
        end if;
    end process;
    
    -- Processus anti-rebond
    process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            count <= 0;
            button_state <= '0';
        elsif rising_edge(i_clk) then
            -- Si l'état du bouton change
            if button_sync(1) /= button_state then
                if count < DEBOUNCE_TIME then
                    count <= count + 1;
                else
                    button_state <= button_sync(1);
                    count <= 0;
                end if;
            else
                count <= 0;
            end if;
        end if;
    end process;
    
    -- Détection de front montant pour ne générer qu'une seule impulsion
    process(i_clk, i_reset)
        variable prev_state : STD_LOGIC := '0';
    begin
        if i_reset = '1' then
            o_button_out <= '0';
            prev_state := '0';
        elsif rising_edge(i_clk) then
            o_button_out <= '0';  -- Par défaut à 0
            
            -- Détection front montant
            if button_state = '1' and prev_state = '0' then
                o_button_out <= '1';
            end if;
            
            prev_state := button_state;
        end if;
    end process;
    
end Behavioral;