----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Alex Saletti
-- 
-- Create Date: 18.03.2019 16:23:56
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC := '0';
           o_we : out STD_LOGIC);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
type STATUS1 is (m1s0,m1s1,m1s2);
type STATUS2 is (m2s0,m2s1,m2s2,m2s3);
type STATUS3 is (m3s0,m3s1,m3s2);
type STATUS4 is (m4s0,m4s1,m4s2,m4s3,m4s4,m4s5);
type STATUS5 is (m5s0,m5c0a,m5c0b,m5c1a,m5c1b,m5c2a,m5c2b,m5c3a,m5c3b,m5c4a,m5c4b,m5c5a,m5c5b,m5c6a,m5c6b,m5c7a,m5c7b,m5s1);
type STATUS6 is (m6s0,m6s1,m6s2,m6s3,m6s4,m6s5,m6s6);
type STATUS7 is (m7s0,m7s1,m7s2,m7s3,m7s4);
type STATUS8 is (m8s0,m8s1,m8s2);
type STATUSREGX is (regxs0,regxs1);
type STATUSREGY is (regys0,regys1);
signal finito, inizia, mletta, rtr, leggi, mok, mnull, ok0, okregxp, okregyp, regxp, regyp, ok2, calcok, startcomp, regx, regy, okregx,okregy, dok, cdist, d1, d2,d3,d4,d5,d6,d7,d8,okcomp,muok,scritto : std_logic := '0'; 
signal en0, en1,en2,en3,en4,en5,en6,en7,en8,en9,en10,en11,en12,en13,en14,en15,en16,en17,en18,en19w : std_logic := '0';
signal m1sc, m1sp : status1 := m1s0; 
signal m2sc, m2sp : status2 := m2s0;
signal m3sc, m3sp : status3 := m3s0; 
signal m4sc, m4sp : status4 := m4s0;
signal m5sc, m5sp : status5 := m5s0;
signal m6sc, m6sp : status6 := m6s0;
signal m7sc, m7sp : status7 := m7s0;
signal m8sc, m8sp : status8 := m8s0;
signal regxsc, regxsp : statusregx := regxs0;
signal regysc, regysp : statusregy := regys0;
signal mask, px, py, x, y, umask : std_logic_vector(7 downto 0) := "00000000";
signal sel : std_logic_vector(3 downto 0) := "1000"; 
signal enable : std_logic := '0';
signal dist, di0,di1,di2,di3,di4,di5,di6,di7,min : std_logic_vector(8 downto 0):= "000000000";
signal scrivi : std_logic_vector(1 downto 0) := "00";
begin
--segnale utile per RAM_MANAGER
enable <= en0 or en1 or en2 or en3 or en4 or en5 or en6 or en7 or en8 or en9 or en10 or en11 or en12 or en13 or en14 or en15 or en16 or en17 or en18 or en19w;

-- processo che consente le transizioni e il reset di tutte le FSM
reset_statiprossimi : process(i_clk, i_rst)
    begin
    if i_rst = '1' then
        m1sc <= m1s0;
        m2sc <= m2s0;
        m3sc <= m3s0;
        m4sc <= m4s0;
        m5sc <= m5s0;
        m6sc <= m6s0;
        m7sc <= m7s0;
        m8sc <= m8s0;
        regxsc <= regxs0;
        regysc <= regys0;
    elsif rising_edge(i_clk) then
        m1sc <= m1sp;
        m2sc <= m2sp;
        m3sc <= m3sp;
        m4sc <= m4sp;
        m5sc <= m5sp;
        m6sc <= m6sp;
        m7sc <= m7sp;
        m8sc <= m8sp;
        regxsc <= regxsp;
        regysc <= regysp;
    end if;
end process;

    
-- processo FSM1 che gestisce l'inizio e riconosce il completamento dell'attività di calcolo
FSM1 : process(m1sc, i_start, finito)
    begin
        case m1sc is
            when m1s0 =>
                inizia <= '0';
                o_done <= '0';
                if i_start = '0' then
                    m1sp <= m1s0;
                else
                    m1sp <= m1s1;
                end if;
            when m1s1 =>
                inizia <= '1';
                o_done <='0';
                if finito = '0' then
                    m1sp <= m1s1;
                else
                    m1sp <= m1s2;
                end if;
            when m1s2 =>
                inizia <= '1';
                o_done <= '1';
                if i_start = '1' then
                    m1sp <= m1s2;
                else
                    m1sp <= m1s0;
                end if;
            end case;    
end process;

-- processo FSM2 controlla che la maschera sia stata letta e salvata opportunamente in un registro
FSM2 : process(m2sc,inizia, mletta, rtr)
    begin
        case m2sc is 
            when m2s0 =>
                en0 <='0';
                leggi <='0';
                mok <='0';
                if inizia = '0' then
                    m2sp <= m2s0;
                else
                    m2sp <= m2s1;
                end if;
            when m2s1 => 
                en0 <= '1';
                leggi <= '0';
                mok <='0';
                if rtr = '0' then
                    m2sp <= m2s1;
                else
                    m2sp <= m2s2;
                end if; 
            when m2s2 =>
                en0 <= '1';
                leggi <= '1';
                mok <= '0';
                if mletta = '0' then
                    m2sp <= m2s2;
                else
                    m2sp <= m2s3;
                end if;
            when m2s3 =>
                en0 <='0';
                leggi <= '1';
                mok <='1';
                m2sp <= m2s3;
            end case;
end process;


-- Processo che gestisce il registro in cui è salvata la maschera
MASKREG : process(leggi, i_clk, i_rst)
    begin
        if i_rst = '1' or leggi = '0' then
            mletta <= '0';
            mask <= "00000000";
        else
            if rising_edge(i_clk) and mletta ='0' then
            mask <= i_data;
            mletta <= '1';
            end if;
        end if;
     end process;


-- Processo che gestisce la lettura dalla RAM
RAM_MANAGER : process(en0, en1,en2,en3,en4,en5,en6,en7,en8,en9,en10,en11,en12,en13,en14,en15,en16,en17,en18,en19w,i_clk)
    begin
    if enable = '1' then
            o_en <= '1';
            if en0 ='1' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                rtr <='1';
                o_we <= '0';
                o_address <= (others => '0');
            elsif en0 ='0' and en1 ='1' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000000001";
            elsif en0 ='0' and en1 ='0' and en2 ='1' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000000010";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='1' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000000011";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='1' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000000100";
            elsif en0 ='1' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='1' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                o_address <= "0000000000000101";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='1' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000000110";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='1' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000000111";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='1' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000001000";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='1' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000001001";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='1' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000001010";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='1' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000001011";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='1' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000001100";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='1' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000001101";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='1' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000001110";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='1' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000001111";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='1' and en17 ='0' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000010000";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='1' and en18 ='0' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000010001";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='1' and en19w ='0' then
                o_we <= '0';
                rtr <='1';
                o_address <= "0000000000010010";
            elsif en0 ='0' and en1 ='0' and en2 ='0' and en3 ='0' and en4 ='0' and en5 ='0' and en6 ='0' and en7 ='0' and en8 ='0' and en9 ='0' and en10 ='0' and en11 ='0' and en12 ='0' and en13 ='0' and en14 ='0' and en15 ='0' and en16 ='0' and en17 ='0' and en18 ='0' and en19w ='1' then
                o_we <= '1';
                rtr <='1';
                o_address <= "0000000000010011";
            else
            o_we <= '0';
            rtr <='0';
            o_address <= "0000000000000000";
            end if; 
    else
        o_we <='0';
        rtr <='0';
        o_address <= "0000000000000000";
        o_en <='0';
    end if;
        
end process; 


-- processo che verifica se la maschera è nulla
FSM3 : process(m3sc, mok)
    begin
        case m3sc is
            when m3s0 =>
                mnull <= '0';
                ok0 <= '0';
                if mok = '1' then
                    if mask = "00000000" or mask = "00000001" or mask = "00000010" or mask = "00000100" or mask = "00001000" or mask = "00010000" or mask = "00100000" or mask = "01000000" or mask = "10000000" then
                        m3sp <= m3s1;
                    else
                        m3sp <= m3s2;
                    end if;
                else
                    m3sp <= m3s0; 
                end if;
            when m3s1 =>
                mnull <= '1';
                ok0 <='0';
                m3sp <= m3s1;
            when m3s2 =>
                mnull <= '0';
                ok0 <='1';
                m3sp <= m3s2;       
            end case;
end process;                       


-- Processo FSM che si occupa di leggere e collocare in appositi registri il centroide di riferimento
FSM4 : process(m4sc,ok0, rtr, okregxp, okregyp)
    begin
    case m4sc is
        when m4s0 =>
            en17 <= '0';
            en18 <='0';
            regxp <= '0';
            regyp <= '0';
            ok2 <= '0';
            if ok0 = '1' then
                m4sp <= m4s1;
            else
                m4sp <= m4s0;
            end if;
        when m4s1 =>
            en17 <= '1';
            en18 <= '0';
            regxp <= '0';
            regyp <= '0';
            ok2 <= '0';
            if rtr = '1' then
                m4sp <= m4s2;
            else 
                m4sp <= m4s1;
            end if;
        when m4s2 =>
            en17 <= '1';
            en18 <= '0';
            regxp <= '1';
            regyp <= '0';
            ok2 <='0';
            if okregxp = '1' then
                m4sp <= m4s3;
            else
                m4sp <= m4s2;
            end if;
        when m4s3 =>
            en17 <='0';
            en18 <='1';
            regxp <='1';
            regyp <='0';
            ok2 <= '0';
            if rtr = '1' then
                m4sp <= m4s4;
            else 
                m4sp <= m4s3;
            end if;
        when m4s4 =>
            en17 <='0';
            en18 <='1';
            regxp <='1';
            regyp <='1';
            ok2 <='0';
            if okregyp ='1' then
                m4sp <= m4s5;
            else
                m4sp <= m4s4;
            end if;
        when m4s5 =>
            en17 <='0';
            en18 <='0';
            regxp <='1';
            regyp <='1';
            ok2 <='1';
            m4sp <= m4s5;
        end case; 
end process;


-- Processi che gestiscono i registri delle coordinate del punto P;
PREGX : process(regxp, i_clk)
    begin
    if regxp = '0' then
        okregxp <= '0';
        px <= "00000000";
    else
        if rising_edge(i_clk) and okregxp <='0' then
        okregxp <= '1';
        px <= i_data;
        end if;
    end if;
end process;


PREGY : process(regyp, i_clk)
    begin
    if regyp = '0' then
        okregyp <= '0';
        py <= "00000000";
    else
        if rising_edge(i_clk) and okregyp <='0' then
        okregyp <= '1';
        py <= i_data;
        end if;
    end if;
end process;


-- FSM che si occupa di inizializzare il calcolo della distanza dei centroidi validi
FSM5 : process(m5sc, calcok, ok2)
    begin
    case m5sc is
        when m5s0 =>
            sel <= "1000";
            startcomp <= '0';
            if ok2 = '1' then
                m5sp <= m5c0a;
            else
                m5sp <= m5s0;
            end if;
        when m5c0a =>
            sel <= "1000";
            startcomp <='0';
            if mask(0) ='0' then
                m5sp <= m5c1a;
            else
                m5sp <= m5c0b;
            end if;
        when m5c0b =>
            sel <= "0000";
            startcomp <= '0';
            if calcok ='0' then
                m5sp <= m5c0b;
            else
                m5sp <= m5c1a;
            end if;
        when m5c1a =>
            sel <= "1000";
            startcomp <='0';
            if mask(1) ='0' then
                m5sp <= m5c2a;
            else
                m5sp <= m5c1b;
            end if;
        when m5c1b =>
            sel <= "0001";
            startcomp <= '0';
            if calcok ='0' then
                m5sp <= m5c1b;
            else
                m5sp <= m5c2a;
            end if;
        when m5c2a =>
            sel <= "1000";
            startcomp <='0';
            if mask(2) ='0' then
                m5sp <= m5c3a;
            else
                m5sp <= m5c2b;
            end if;
        when m5c2b =>
            sel <= "0010";
            startcomp <= '0';
            if calcok ='0' then
                m5sp <= m5c2b;
            else
                m5sp <= m5c3a;
            end if;
        when m5c3a =>
            sel <= "1000";
            startcomp <='0';
            if mask(3) ='0' then
                m5sp <= m5c4a;
            else
                m5sp <= m5c3b;
            end if;
        when m5c3b =>
            sel <= "0011";
            startcomp <= '0';
            if calcok ='0' then
                m5sp <= m5c3b;
            else
                m5sp <= m5c4a;
            end if;
        when m5c4a =>
            sel <= "1000";
            startcomp <='0';
            if mask(4) ='0' then
                m5sp <= m5c5a;
            else
                m5sp <= m5c4b;
            end if;
        when m5c4b =>
            sel <= "0100";
            startcomp <= '0';
            if calcok ='0' then
                m5sp <= m5c4b;
            else
                m5sp <= m5c5a;
            end if;
        when m5c5a =>
            sel <= "1000";
            startcomp <='0';
            if mask(5) ='0' then
                m5sp <= m5c6a;
            else
                m5sp <= m5c5b;
            end if;
        when m5c5b =>
            sel <= "0101";
            startcomp <= '0';
            if calcok ='0' then
                m5sp <= m5c5b;
            else
                m5sp <= m5c6a;
            end if; 
        when m5c6a =>
            sel <= "1000";
            startcomp <='0';
            if mask(6) ='0' then
                m5sp <= m5c7a;
            else
                m5sp <= m5c6b;
            end if;
        when m5c6b =>
            sel <= "0110";
            startcomp <= '0';
            if calcok ='0' then
                m5sp <= m5c6b;
            else
                m5sp <= m5c7a;
            end if;
        when m5c7a =>
            sel <= "1000";
            startcomp <='0';
            if mask(7) ='0' then
                m5sp <= m5s1;
            else
                m5sp <= m5c7b;
            end if;
        when m5c7b =>
            sel <= "0111";
            startcomp <= '0';
            if calcok ='0' then
                m5sp <= m5c7b;
            else
                m5sp <= m5s1;
            end if;
        when m5s1 =>
            sel <= "1000";
            startcomp <= '1';
            m5sp <= m5s1;
        end case;
end process;

-- FSM che calcola le distanze necessarie
FSM6 : process(sel, m6sc, rtr, okregx,okregy,dok)
    begin
    case m6sc is
        when m6s0 =>
            en1 <='0';
            en2 <='0';
            en3 <='0';
            en4 <='0';
            en5 <='0';
            en6 <='0';
            en7 <='0';
            en8 <='0';
            en9 <='0';
            en11 <='0';
            en12 <='0';
            en13 <='0';
            en14 <='0';
            en15 <='0';
            en16 <='0';
            regx <='0';
            regy <='0';
            cdist <='0';
            calcok <='0';
            if sel = "1000" then
                m6sp <= m6s0;
            else
                m6sp <= m6s1;
            end if;
        when m6s1 =>
            regx <='0';
            regy <='0';
            cdist <='0';
            calcok <='0';
            if sel = "0000" then
                en1 <='1';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0001" then
                en1 <='0';
                en2 <='0';
                en3 <='1';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0010" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='1';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0011" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='1';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0100" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='1';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0101" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='1';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0'; 
            elsif sel = "0110" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='1';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0111" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='1';
                en16 <='0';
            elsif sel = "1000" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            end if;
            if rtr ='0' then
                m6sp <= m6s1;
            else
                m6sp <= m6s2;
            end if;
        when m6s2 =>
            regx <='1';
            regy <='0';
            cdist <='0';
            calcok <='0';
            if sel = "0000" then
                en1 <='1';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0001" then
                en1 <='0';
                en2 <='0';
                en3 <='1';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0010" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='1';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0011" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='1';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0100" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='1';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0101" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='1';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0'; 
            elsif sel = "0110" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='1';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0111" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='1';
                en16 <='0';
            elsif sel = "1000" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            end if;
            if okregx = '1' then
                m6sp <= m6s3;
            else
                m6sp <= m6s2;
            end if;
        when m6s3 =>
            regx <='1';
            regy <='0';
            cdist <='0';
            calcok <='0';
            if sel = "0000" then
                en1 <='0';
                en2 <='1';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0001" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='1';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0010" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='1';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0011" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='1';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0100" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='1';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0101" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='1';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0'; 
            elsif sel = "0110" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='1';
                en15 <='0';
                en16 <='0'; 
            elsif sel = "0111" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='1';
            elsif sel = "1000" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            end if;
            if rtr = '1' then
                m6sp <= m6s4;
            else
                m6sp <= m6s3;
            end if;
        when m6s4 =>
            regx <='1';
            regy <='1';
            cdist <='0';
            calcok <='0';
            if sel = "0000" then
                en1 <='0';
                en2 <='1';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0001" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='1';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0010" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='1';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0011" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='1';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0100" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='1';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            elsif sel = "0101" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='1';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0'; 
            elsif sel = "0110" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='1';
                en15 <='0';
                en16 <='0'; 
            elsif sel = "0111" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='1';
            elsif sel = "1000" then
                en1 <='0';
                en2 <='0';
                en3 <='0';
                en4 <='0';
                en5 <='0';
                en6 <='0';
                en7 <='0';
                en8 <='0';
                en9 <='0';
                en10 <='0';
                en11 <='0';
                en12 <='0';
                en13 <='0';
                en14 <='0';
                en15 <='0';
                en16 <='0';
            end if;
            if okregy ='1' then
                m6sp <= m6s5;
            else
                m6sp <= m6s4;
            end if;
        when m6s5 =>
            regx <='1';
            regy <='1';
            cdist <='1';
            calcok <='0';
            en1 <='0';
            en2 <='0';
            en3 <='0';
            en4 <='0';
            en5 <='0';
            en6 <='0';
            en7 <='0';
            en8 <='0';
            en9 <='0';
            en10 <='0';
            en11 <='0';
            en12 <='0';
            en13 <='0';
            en14 <='0';
            en15 <='0';
            en16 <='0';
            if dok ='1' then
                m6sp <= m6s6;
            else 
                m6sp <= m6s5;
            end if;
        when m6s6 =>
            regx <='0';
            regy <='0';
            cdist <='0';
            calcok <='1';
            en1 <='0';
            en2 <='0';
            en3 <='0';
            en4 <='0';
            en5 <='0';
            en6 <='0';
            en7 <='0';
            en8 <='0';
            en9 <='0';
            en10 <='0';
            en11 <='0';
            en12 <='0';
            en13 <='0';
            en14 <='0';
            en15 <='0';
            en16 <='0';
            if sel = "1000" then
                m6sp <= m6s0;
            else 
                m6sp <= m6s6;
            end if;
        end case;
end process; 


-- Registri che salvano coordinate dei centroidi
REGISTROX : process(regxsc, regx)
    begin
    case regxsc is
        when regxs0 => 
            x <= (others => '0');
            okregx <= '0';
            if regx = '1' then
                regxsp <= regxs1;
            else
                regxsp <= regxs0;
            end if;
        when regxs1 =>
            x <= i_data;
            okregx <= '1';
            if regx = '1' then
                regxsp <= regxs1;
            else
                regxsp <= regxs0;
            end if;
        end case;
    end process;
    
    
REGISTROY : process(regysc, regy)
    begin
    case regysc is
        when regys0 => 
            y <= (others => '0');
            okregy <= '0';
            if regy = '1' then
                regysp <= regys1;
            else
                regysp <= regys0;
            end if;
        when regys1 =>
            y <= i_data;
            okregy <= '1';
            if regy = '1' then
                regysp <= regys1;
            else
                regysp <= regys0;
            end if;
        end case;
    end process;

  
    
                      
-- Processo che calcola la distanza di Manhattan
MAHNDIST : process(cdist)
    variable pxs, xs, pys, ys : unsigned(7 downto 0) := "00000000";
    variable dx,dy : unsigned(8 downto 0) := "000000000";
    variable udist : std_logic_vector(7 downto 0) := "00000000";
    begin
    if cdist = '1' then
        pxs := unsigned(px);
        xs := unsigned(x);
        pys := unsigned(py);
        ys := unsigned(y);
        if pxs>xs then
            dx := '0' & (pxs-xs);
        else
            dx := '0' & (xs-pxs);
        end if;
        if pys>ys then
            dy := '0' & (pys-ys);
        else
            dy := '0' & (ys-pys);
        end if;
        dist <= std_logic_vector(dx+dy);
        if sel = "0000" then
            d1 <='1'; d2 <= '0'; d3 <='0'; d4 <='0'; d5 <='0'; d6 <='0'; d7 <='0'; d8 <='0';
        elsif sel = "0001" then
            d1 <='1'; d2 <= '1'; d3 <='0'; d4 <='0'; d5 <='0'; d6 <='0'; d7 <='0'; d8 <='0';
        elsif sel = "0010" then
            d1 <='1'; d2 <= '1'; d3 <='1'; d4 <='0'; d5 <='0'; d6 <='0'; d7 <='0'; d8 <='0';
        elsif sel = "0011" then
            d1 <='1'; d2 <= '1'; d3 <='1'; d4 <='1'; d5 <='0'; d6 <='0'; d7 <='0'; d8 <='0';
        elsif sel = "0100" then
            d1 <='1'; d2 <= '1'; d3 <='1'; d4 <='1'; d5 <='1'; d6 <='0'; d7 <='0'; d8 <='0';
        elsif sel = "0101" then
            d1 <='1'; d2 <= '1'; d3 <='1'; d4 <='1'; d5 <='1'; d6 <='1'; d7 <='0'; d8 <='0';
        elsif sel = "0110" then
            d1 <='1'; d2 <= '1'; d3 <='1'; d4 <='1'; d5 <='1'; d6 <='1'; d7 <='1'; d8 <='0';
        elsif sel = "0111" then
            d1 <='1'; d2 <= '1'; d3 <='1'; d4 <='1'; d5 <='1'; d6 <='1'; d7 <='1'; d8 <='1';
        end if;
        dok <= '1';
    else
        dok <='0';
    end if;
end process;


--Registri che salvano distanze
REG1 : process(d1)
    begin
    if d1 = '1' then
        di0 <= dist;
    end if;
    end process;  
REG2 : process(d2)
    begin
    if d2 = '1' then
        di1 <= dist;
    end if;
    end process; 
REG3 : process(d3)
    begin
    if d3 = '1' then
        di2 <= dist;
    end if;
    end process;                    
REG4 : process(d4)
    begin
    if d4 = '1' then
        di3 <= dist;
    end if;
    end process;         
REG5 : process(d5)
    begin
    if d5 = '1' then
        di4 <= dist;
    end if;
    end process;
REG6 : process(d6)
    begin
    if d6 = '1' then
        di5 <= dist;
    end if;
    end process;
REG7 : process(d7)
    begin
    if d7 = '1' then
        di6 <= dist;
    end if;
    end process; 
REG8 : process(d8)
    begin
    if d8 = '1' then
        di7 <= dist;
    end if;
    end process; 
    
    
-- Processo che realizza il comparatore
COMPARE : process(startcomp)
    variable sig1, sig2, sig3,sig4, sig12, sig34 : std_logic_vector(8 downto 0) := "000000000";
    variable v1,v2,v3,v4,v12,v34 : std_logic :='0';
    begin
    if startcomp ='1' then
    
    if mask(0) ='1' and mask(1) = '1' then
        v1 := '1';
        if unsigned(di0)<unsigned(di1) then
            sig1 := di0;
        else
            sig1 := di1;
        end if;
    elsif mask(0) = '0' and mask(1) = '1' then
        sig1 := di1;
        v1 := '1';
    elsif mask(0) = '1' and mask(1) = '0' then
        sig1 := di0;
        v1 := '1';
    else
        v1 :='0';
        sig1 :="000000000";
    end if;
        
    if mask(2) ='1' and mask(3) = '1' then
        v2 := '1';
        if unsigned(di2)<unsigned(di3) then
            sig2 := di2;
        else
            sig2 := di3;
        end if;
    elsif mask(2) = '0' and mask(3) = '1' then
        sig2 := di3;
        v2 := '1';
    elsif mask(2) = '1' and mask(3) = '0' then
        sig2 := di2;
        v2 := '1';
    else
        v2 :='0';
        sig2 :="000000000";
    end if; 
    
    if mask(4) ='1' and mask(5) = '1' then
        v3 := '1';
        if unsigned(di4)<unsigned(di5) then
            sig3 := di4;
        else
            sig3 := di5;
        end if;
    elsif mask(4) = '0' and mask(5) = '1' then
        sig3 := di5;
        v3 := '1';
    elsif mask(4) = '1' and mask(5) = '0' then
        sig3 := di4;
        v3 := '1';
    else
        v3 :='0';
        sig3 :="000000000";
    end if;
    
    if mask(6) ='1' and mask(7) = '1' then
        v4 := '1';
        if unsigned(di6)<unsigned(di7) then
            sig4 := di6;
        else
            sig4 := di7;
        end if;
    elsif mask(6) = '0' and mask(7) = '1' then
        sig4 := di7;
        v4 := '1';
    elsif mask(6) = '1' and mask(7) = '0' then
        sig4 := di6;
        v4 := '1';
    else
        v4 :='0';
        sig4 :="000000000";
    end if;   
    
    if v1 ='1' and v2 = '1' then
        v12 := '1';
        if unsigned(sig1)<unsigned(sig2) then
            sig12 := sig1;
        else
            sig12 := sig2;
        end if;
    elsif v1 = '0' and v2 = '1' then
        sig12 := sig2;
        v12 := '1';
    elsif v1 = '1' and v2 = '0' then
        sig12 :=sig1;
        v12 := '1';
    else
        v12 :='0';
        sig12 :="000000000";
    end if;
    
    if v3 ='1' and v4 = '1' then
        v34 := '1';
        if unsigned(sig3)<unsigned(sig4) then
            sig34 := sig3;
        else
            sig34 := sig4;
        end if;
    elsif v3 = '0' and v4 = '1' then
        sig34 := sig4;
        v4 := '1';
    elsif v3 = '1' and v4 = '0' then
        sig34 := sig3;
        v4 := '1';
    else
        v4 :='0';
        sig34 :="000000000";
    end if;
    
    if v12 ='1' and v34 = '1' then
        if unsigned(sig12)<unsigned(sig34) then
            min <= sig12;
            okcomp <='1';
        else
            min <= sig34;
            okcomp <='1';
        end if;
    elsif v12 = '0' and v34 = '1' then
        min <= sig34;
        okcomp <= '1';
    elsif v3 = '1' and v4 = '0' then
        min <= sig12;
        okcomp <= '1';
    else
        min <= "000000000";
        okcomp <='0';
    end if; 
    else
        min <="000000000";
        okcomp <='0';
    end if;                     
end process;

-- Processo che confronta le distanze e gestisce l'uscita
UMASKGEN : process(okcomp)
    begin
    if okcomp = '0' then
        umask <= "00000000";
        muok <='0';
    else
        if min = di0 and mask(0) ='1' then
            umask(0) <= '1';
        else
            umask(0) <='0';
        end if;
        if min = di1 and mask(1) ='1' then
            umask(1) <='1';
        else
            umask(1) <='0';
        end if;
        if min = di2 and mask(2) ='1' then
            umask(2) <='1';
        else
            umask(2) <='0';
        end if;
        if min = di3 and mask(3) ='1' then
            umask(3) <='1';
        else
            umask(3) <='0';
        end if;
        if min = di4 and mask(4) ='1' then
            umask(4) <='1';
        else
            umask(4) <='0';
        end if;
        if min = di5 and mask(5) ='1' then
            umask(5) <='1';
        else
            umask(5) <='0';
        end if;
        if min = di6 and mask(6) ='1' then
            umask(6) <='1';
        else
            umask(6) <='0';
        end if;
        if min = di7 and mask(7) ='1' then
            umask(7) <='1';
        else
            umask(7) <='0';
        end if;
        muok <='1';
        end if;
end process;


--Processo che gestisce la scrittura di umask
FSM7 : process(m7sc,rtr,muok,mnull,scritto)
    begin
        case m7sc is
            when m7s0 =>
                scrivi <= "00";
                en19w <= '0';
                finito <= '0';
                if muok = '1' or mnull = '1' then
                    m7sp <= m7s1;
                else
                    m7sp <= m7s0;
                end if;
            when m7s1 =>
                scrivi <="00";
                en19w <= '1';
                finito <='0';
                if rtr = '1' then
                    if mnull = '1' then
                        m7sp <= m7s2;
                    else
                        m7sp <= m7s3;
                    end if;
                else
                    m7sp <= m7s1;
                end if;
            when m7s2 =>
                scrivi <= "10";
                en19w <= '1';
                finito <='0';
                if scritto ='1' then
                    m7sp <= m7s4;
                else
                    m7sp <= m7s2;
                end if;
            when m7s3 =>
                scrivi <= "01";
                en19w <= '1';
                finito <='0';
                if scritto ='1' then
                    m7sp <= m7s4;
                else
                    m7sp <= m7s3;
                end if;
            when m7s4 =>
                scrivi <="00";
                en19w <='0';
                finito <='1';
                m7sp <= m7s4;
            end case;
end process;

--Processo che scrive umask
FSM8 : process(m8sc,scrivi)
    begin
    case m8sc is
        when m8s0 =>
            scritto <='0';
            o_data <="00000000";
            if scrivi = "01" then
                m8sp <= m8s1;
            elsif scrivi = "10" then
                m8sp <= m8s2;
            else
                m8sp <= m8s0;
            end if;
        when m8s1 =>
            scritto <='1';
            o_data <= umask;
            m8sp <= m8s1;
        when m8s2 =>
            scritto <='1';
            o_data <= mask;
            m8sp <=m8s2;
        end case; 
end process;                
                          
end Behavioral;
