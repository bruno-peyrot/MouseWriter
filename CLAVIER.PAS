program clavier_fictif;

uses dos,crt,graph,turbolib,graphlib;

var shift,caps,vraiclavier,fonction:boolean;
    car,nul,rc,touche:char;



procedure Dessine_Clavier;
{ Dessine le clavier ainsi que le bloc des touches de fonction }

var m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11:char;
    i,ligne:integer;
    chaine,ch2:string;

begin
     ligne:=24;

     { Dessine le clavier principal }
     coulTexte(Blanc);
     m1:=chr(179);   m2:=chr(180);   m3:=chr(191);   m4:=chr(192);
     m5:=chr(193);   m6:=chr(194);   m7:=chr(195);   m8:=chr(196);
     m9:=chr(197);   m10:=chr(217);  m11:=chr(218);
     chaine:=m11;
     for i:=1 to 13 do chaine:=chaine+m8+m8+m8+m6;
     for i:=1 to 7 do chaine:=chaine+m8;
     chaine:=chaine+m3;
     gotoxy(1,ligne);
     write(graf,chaine);
     chaine:='';
     for i:=1 to 13 do chaine:=chaine+m1+'   ';
     chaine:=chaine+m1+'       '+m1;
     gotoxy(1,ligne+1);
     write(graf,chaine);
     chaine:=m7+m8+m8+m8;
     for i:=1 to 13 do chaine:=chaine+m5+m8+m6+m8;
     chaine:=chaine+m8+m8+m8+m8+m2;
     gotoxy(1,ligne+2);
     write(graf,chaine);
     chaine:=m1+'     ';
     for i:=1 to 13 do chaine:=chaine+m1+'   ';
     chaine:=chaine+'  '+m1;
     gotoxy(1,ligne+3);
     write(graf,chaine);
     chaine:=m7+m8+m8+m8+m8+m8;
     for i:=1 to 12 do chaine:=chaine+m5+m8+m6+m8;
     chaine:=chaine+m5+m8+m3+'   '+m1;
     gotoxy(1,ligne+4);
     write(graf,chaine);
     chaine:=m1+'       ';
     for i:=1 to 13 do chaine:=chaine+m1+'   ';
     chaine:=chaine+m1;
     gotoxy(1,ligne+5);
     write(graf,chaine);
     chaine:=m7+m8+m8+m8+m8+m8+m6+m8;
     for i:=1 to 11 do chaine:=chaine+m5+m8+m6+m8;
     chaine:=chaine+m5+m8+m8+m8+m5+m8+m8+m8+m2;
     gotoxy(1,ligne+6);
     write(graf,chaine);
     chaine:=m1+'     ';
     for i:=1 to 12 do chaine:=chaine+m1+'   ';
     chaine:=chaine+'      '+m1;
     gotoxy(1,ligne+7);
     write(graf,chaine);
     chaine:=m4+m8+m8+m8+m8+m8+m5+m8+m8+m8+m5+m8+m8+m8+m5+m8+m6;
     for i:=1 to 6 do chaine:=chaine+m8+m5+m8+m8;
     chaine:=chaine+m8+m5+m8+m6+m8+m5+m8+m8+m8+m5;
     for i:=1 to 9 do chaine:=chaine+m8;
     chaine:=chaine+m10;
     gotoxy(1,ligne+8);
     write(graf,chaine);
     chaine:=m1+'                           '+m1;
     gotoxy(17,ligne+9);
     write(graf,chaine);
     chaine:=m4;
     for i:=1 to 27 do chaine:=chaine+m8;
     chaine:=chaine+m10;
     gotoxy(17,ligne+10);
     write(graf,chaine);

     { Dessine le pav‚ des touches de fonction }
     chaine:=m11+m8+m8+m8+m6+m8+m8+m8+m6+m8+m8+m8+m6+m8+m8+m8+m3;
     gotoxy(64,ligne+2);
     write(graf,chaine);
     ch2:=chr(17)+chr(24)+chr(16)+chr(30);
     chaine:=m1;
     for i:=1 to 4 do chaine:=chaine+' '+copy(ch2,i,1)+' '+m1;
     gotoxy(64,ligne+3);
     write(graf,chaine);
     chaine:=m7+m8+m8+m8+m9+m8+m8+m8+m9+m8+m8+m8+m9+m8+m8+m8+m2;
     gotoxy(64,ligne+4);
     write(graf,chaine);
     ch2:=chr(27)+chr(25)+chr(26)+chr(31);
     chaine:=m1;
     for i:=1 to 4 do chaine:=chaine+' '+copy(ch2,i,1)+' '+m1;
     gotoxy(64,ligne+5);
     write(graf,chaine);
     chaine:=m4+m8+m8+m8+m5+m8+m8+m8+m5+m8+m8+m8+m5+m8+m8+m8+m10;
     gotoxy(64,ligne+6);
     write(graf,chaine);
end;



procedure Dessine_Touches;
{ Dessine le contenu des touches, suivant la valeur du drapeau 'shift' }

var i,j,ligne:integer;
    chaine:array[1..4] of string;

begin
    ligne:=24;
    if shift then
        begin
            { D‚finition du clavier MAJUSCULE }
            chaine[1]:='1234567890ø+';
            chaine[2]:='AZERTYUIOP~œ';
            chaine[3]:='QSDFGHJKLM%æ';
            chaine[4]:='>WXCVBN?./'+chr(21);
        end
             else
        begin
            { D‚finition du clavier MINUSCULE }
            chaine[1]:='&‚"'+chr(39)+'(-Š_‡…)=';
            chaine[2]:='azertyuiop^$';
            chaine[3]:='qsdfghjklm—*';
            chaine[4]:='<wxcvbn,;:!';
        end;

    { Affiche le contenu de chaque touche }
    coulTexte(Blanc);
    for i:=1 to 3 do
        for j:=1 to 12 do
            begin
                gotoxy(4*j+2*i+1,ligne+2*i-1);
                write(graf,copy(chaine[i],j,1));
            end;
    for i:=1 to 11 do
        begin
            gotoxy(4*i+5,ligne+7);
            write(graf,copy(chaine[4],i,1));
        end;

    { Affiche le contenu des touches 'sp‚ciales' du clavier }
    coulTexte(Jaune);
    if shift then
        begin
            gotoxy(2,ligne+1);
            write(graf,'ESC');
            gotoxy(56,ligne+1);
            write(graf,'DEL');
            gotoxy(3,ligne+3);
            write(graf,'TAB');
            gotoxy(3,ligne+5);
            write(graf,'CAPS');
            gotoxy(2,ligne+7);
            write(graf,'SHIFT');
            gotoxy(54,ligne+7);
            write(graf,'SHIFT');
        end
             else
        begin
            gotoxy(2,ligne+1);
            write(graf,'esc');
            gotoxy(56,ligne+1);
            write(graf,'del');
            gotoxy(3,ligne+3);
            write(graf,'tab');
            gotoxy(3,ligne+5);
            write(graf,'caps');
            gotoxy(2,ligne+7);
            write(graf,'shift');
            gotoxy(54,ligne+7);
            write(graf,'shift');
        end;
    coultexte(Blanc);
end;



function Lit_Clavier:char;

var t,s:string;
    x,y,l,i:integer;

begin
  fonction:=false;
  t:=nul;
  l:=0;
  x:=posSouris.x;
  y:=posSouris.y;
  for i:=1 to 5 do
    if (y>=28*i+302) and (y<=28*i+327) then l:=i;
  if l=1 then
    begin
      if shift then s:=chr(27)+'1234567890ø+'
               else s:=chr(27)+'&‚"'+chr(39)+'(-Š_‡…)=';
      for i:=1 to 13 do
        if (x>=32*i-27) and (x<=32*i+1) then t:=copy(s,i,1);
      if (x>=421) and (x<=481) then t:=chr(8);
    end
         else
    if l=2 then
      begin
        if shift then s:='AZERTYUIOP~œ'
                 else s:='azertyuiop^$';
        for i:=1 to 12 do
          if (x>=32*i+21) and (x<=32*i+49) then t:=copy(s,i,1);
        if (x>=5) and (x<=49) then t:=chr(9);
        if (x>=437) and (x<=481) then t:=rc;
        s:=chr(71)+chr(72)+chr(79)+chr(73);
        for i:=1 to 4 do
          if (x>=32*i+477) and (x<=32*i+537) then
            begin
              t:=copy(s,i,1);
              fonction:=true;
            end;
      end
           else
      if l=3 then
        begin
          if shift then s:='QSDFGHJKLM%æ'
                   else s:='qsdfghjklm—*';
          for i:=1 to 12 do
            if (x>=32*i+37) and (x<=32*i+65) then t:=copy(s,i,1);
          if (x>=5) and (x<=65) then
            begin
              if caps then
                begin
                  caps:=false;
                  shift:=false;
                end
                      else
                begin
                  caps:=true;
                  shift:=true;
                end;
              Dessine_Touches;
            end;
          if (x>=453) and (x<=481) then t:=rc;
          s:=chr(75)+chr(80)+chr(77)+chr(81);
          for i:=1 to 4 do
            if (x>=32*i+477) and (x<=32*i+537) then
              begin
                t:=copy(s,i,1);
                fonction:=true;
              end;
        end
             else
        if l=4 then
          begin
            if shift then s:='>WXCVBN?./'+chr(21)
                     else s:='<wxcvbn,;:!';
            for i:=1 to 11 do
              if (x>=32*i+21) and (x<=32*i+49) then t:=copy(s,i,1);
            if ((x>=5) and (x<=49)) or ((x>=405) and (x<=481)) then
              begin
                if caps then caps:=false;
                shift:=not(shift);
                Dessine_Touches;
              end;
          end
               else
          if l=5 then
            if (x>=133) and (x<=353) then t:=' ';
  if (t=nul) and (y<14) then
    begin
      fonction:=true;
      if (x>=17) and (x<=103) then t:=chr(30);
      if (x>=129) and (x<=184) then t:=chr(49);
      if (x>=209) and (x<=265) then t:=chr(38);
      if (x>=289) and (x<=368) then t:=chr(31);
      if (x>=394) and (x<=473) then t:=chr(23);
      if (x>=569) and (x<=625) then t:=chr(16);
    end;
  if t<>nul then
    if shift and not(caps) then
      begin
        shift:=false;
        Dessine_Touches;
      end;
  Lit_Clavier:=t[1];
end;



procedure Affiche_Menu;
{ Affiche la barre de menu }

var st:string;

begin
    gotoxy(1,1);
    coulTexte(Blanc);
    st:='   _propos_de    ouveau    ecture    auvegarde    mpression';
    st:=st+'             uitter';
    write(graf,st);
    coulTexte(Rouge);
    gotoxy(3,1);
    write(graf,'A');
    gotoxy(17,1);
    write(graf,'N');
    gotoxy(27,1);
    write(graf,'L');
    gotoxy(37,1);
    write(graf,'S');
    gotoxy(50,1);
    write(graf,'I');
    gotoxy(72,1);
    write(graf,'Q');
end;



begin
    nul:=chr(0);
    rc:=chr(13);
    shift:=false;
    caps:=false;
    modeGraphique;
    Affiche_Menu;
    Dessine_Clavier;
    Dessine_Touches;
    repeat
        repeat
            vraiclavier:=false;
            fonction:=false;
            repeat
                execSouris;
                if keypressed then vraiclavier:=true;
            until (boutSouris=1) or vraiclavier;
            if boutSouris=1 then
                                begin
                                    touche:=Lit_Clavier;
                                    repeat
                                        execSouris;
                                    until boutSouris=0;
                                end
                            else
                                begin
                                    touche:=readkey;
                                    if touche=nul then
                                        begin
                                            touche:=readkey;
                                            fonction:=true;
                                        end;
                                    while keypressed do car:=readkey;
                                end;
        until touche<>nul;
        gotoxy(1,3);
        write(graf,ord(touche));
        write(graf,'     ');
        gotoxy(1,4);
        write(graf,touche+'     ');
        gotoxy(1,5);
        if fonction then write(graf,'1')
                    else write(graf,'0');
    until touche=chr(27);
    modeTexte;
end.