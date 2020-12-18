

{

               Editeur de texte pilotÇ Ö la souris
                  MouseWriter v3.0 (xx/xx/1995)
                        par PEYROT Bruno
                     DÇdiÇ Ö Claude Londeix


}



program MouseWriter;


uses dos,crt,graph,turbolib,graphli2,printer;


const nmax=500;
{ nmax reprÇsente le nombre maximum de lignes que peut gÇrer le programme }


{
DÇfinition des variables:
x,y: position du curseur dans le texte
lh: numÇro de la premiäre ligne de texte affichÇe
nl: nombre de lignes de la fenàtre texte
nfin: numÇro de la derniäre ligne de texte
langage: choix de la langue (1:Franáais, 2:Anglais, 3:Allemand, 4:Espagnol,
                             5:Italien,  6:AmÇricain)
fini: drapeau indiquant la fin Çventuelle du programme
textemem: drapeau indiquant qu'un texte est en mÇmoire ou non
modif: drapeau indiquant si le texte a ÇtÇ modifiÇ ou non
input: drapeau indiquant la saisie d'un nom
shift,caps,fonction: drapeaux indiquant l'Çtat du clavier fictif
nomfichier: nom du fichier en mÇmoire
touchesdepl: codes des touches de dÇplacement
touchesfonc: codes des touches de fonction
affichable: liste de tous les caractäres affichables
t: tableau de chaånes contenant le texte
}


var i,lh,nl,nfin,x,y,langage:integer;
    fini,textemem,modif,input,shift,caps,fonction:boolean;
    nul,del,tab,rc,touche:char;
    nomfichier,lignevide,lignegrise,touchesdepl,touchesfonc:string;
    affichable:string;
    t:array[1..nmax] of string[80];



{ ProcÇdures et fonctions }


procedure Cadre_Drapeau(l:integer);
{ Dessine un petit cadre autour du drapeau choisi }

begin
    moveto(478+40*langage,438);
    lineto(478+40*langage,455);
    lineto(505+40*langage,455);
    lineto(505+40*langage,438);
    lineto(478+40*langage,438);
end;



procedure Dessine_Clavier;
{ Dessine le clavier ainsi que le bloc des touches de fonction }

var m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11:char;
    i,ligne:integer;
    chaine,ch2:string;

begin
     ligne:=24;
     coulFond(Noir);
     coulTexte(Noir);
     gotoxy(1,34);
     write(graf,chr(219));

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

     { Dessine le pavÇ des touches de fonction }
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

     { Dessine les drapeaux }
     setcolor(gris);
     for i:=430 to 463 do line(510,i,633,i);
     setcolor(Blanc);
     Cadre_Drapeau(langage);

     { Drapeau franáais }
     setcolor(Bleu);
     for i:=440 to 453 do line (520,i,527,i);
     setcolor(Blanc);
     for i:=440 to 453 do line(528,i,535,i);
     setcolor(Rouge);
     for i:=440 to 453 do line(536,i,543,i);

     { Drapeau anglais }
     setcolor(bleu);
     for i:=440 to 453 do line(560,i,583,i);
     setcolor(blanc);
     line(569,440,569,453);   line(574,440,574,453);
     line(560,445,583,445);   line(560,448,583,448);
     line(561,440,583,452);   line(560,441,582,453);
     line(582,440,560,452);   line(583,441,561,453);
     setcolor(Rouge);
     for i:=1 to 4 do line(569+i,440,569+i,453);
     for i:=1 to 2 do line(560,445+i,583,445+i);
     line(560,440,567,444);   line(576,449,583,453);
     line(583,440,576,444);   line(567,449,560,453);

     { Drapeau allemand }
     setcolor(noir);
     for i:=440 to 444 do line(600,i,623,i);
     setcolor(rouge);
     for i:=445 to 448 do line(600,i,623,i);
     setcolor(jaune);
     for i:=449 to 453 do line(600,i,623,i);
end;



procedure Dessine_Touches;
{ Dessine le contenu des touches, suivant la valeur du drapeau 'shift' }

var i,j,ligne:integer;
    chaine:array[1..4] of string;

begin
    ligne:=24;
    coulFond(Noir);
    coulTexte(Noir);
    gotoxy(1,34);
    write(graf,chr(219));
    case langage of
        1: { DÇfinition du clavier langue franáaise }
           begin
               if shift then
                   begin
                       { DÇfinition du clavier MAJUSCULE }
                       chaine[1]:='1234567890¯+';
                       chaine[2]:='AZERTYUIOP~ú';
                       chaine[3]:='QSDFGHJKLM%Ê';
                       chaine[4]:='>WXCVBN?./'+chr(21);
                   end
                        else
                   begin
                       { DÇfinition du clavier MINUSCULE }
                       chaine[1]:='&Ç"'+chr(39)+'(-ä_áÖ)=';
                       chaine[2]:='azertyuiop^$';
                       chaine[3]:='qsdfghjklmó*';
                       chaine[4]:='<wxcvbn,;:!';
                   end;
           end;
        2: { DÇfinition du clavier langue anglaise }
           begin
               if shift then
                   begin
                       { DÇfinition du clavier MAJUSCULE }
                       chaine[1]:='!"ú$%^&*()_+';
                       chaine[2]:='QWERTYUIOP{}';
                       chaine[3]:='ASDFGHJKL:@~';
                       chaine[4]:='|ZXCVBNM<>?';
                   end
                        else
                   begin
                       { DÇfinition du clavier MINUSCULE }
                       chaine[1]:='1234567890-=';
                       chaine[2]:='qwertyuiop[]';
                       chaine[3]:='asdfghjkl;'+chr(39)+'#';
                       chaine[4]:='\zxcvbnm,./';
                   end;
           end;
        3: { DÇfinition du clavier langue allemande }
           begin
               if shift then
                   begin
                       { DÇfinition du clavier MAJUSCULE }
                       chaine[1]:='!"'+chr(21)+'$%&/()=?`';
                       chaine[2]:='QWERTZUIOPö*';
                       chaine[3]:='ASDFGHJKLôé'+chr(39);
                       chaine[4]:='>YXCVBNM;:_';
                   end
                        else
                   begin
                       { DÇfinition du clavier MINUSCULE }
                       chaine[1]:='1234567890'+chr(225)+chr(39);
                       chaine[2]:='qwertzuiopÅ+';
                       chaine[3]:='asdfghjklîÑ#';
                       chaine[4]:='<yxcvbnm,.-';
                   end;
           end;
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

    { Affiche le contenu des touches 'spÇciales' du clavier }
    coulTexte(Jaune);
    if shift then
        begin
            gotoxy(2,ligne+1);
            write(graf,'ESC');
            gotoxy(56,ligne+1);
            write(graf,'DEL');
            gotoxy(3,ligne+3);
            write(graf,'TAB');
            gotoxy(4,ligne+5);
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
            gotoxy(4,ligne+5);
            write(graf,'caps');
            gotoxy(2,ligne+7);
            write(graf,'shift');
            gotoxy(54,ligne+7);
            write(graf,'shift');
        end;
        if caps then
            begin
                coulTexte(Orange);
                gotoxy(2,ligne+5);
                write(graf,chr(254));
            end
                else
            begin
                coulTexte(Rouge);
                gotoxy(2,ligne+5);
                write(graf,chr(254));
            end;

    { Indicateur de modification de texte }
    if textemem then
        begin
            coulFond(Noir);
            coulTexte(Blanc);
            gotoxy(1,34);
            if modif then
                write(graf,'*')
                     else
                write(graf,' ');
        end;
    coultexte(Blanc);
end;



procedure Affiche_Curseur;
{ Affiche le curseur texte }

begin
  gotoxy(x,y-lh+2);
  if length(T[y])<x then
     begin
       coulFond(Noir);
       coulTexte(Noir);
       write(graf,chr(219));
     end
                    else
     begin
       CoulFond(Noir);
       CoulTexte(Noir);
       write(graf,chr(219));
       gotoxy(x,y-lh+2);
       CoulTexte(GrisClair);
       write(graf,copy(T[Y],x,1));
     end;
end;


procedure Eteind_Curseur;
{ Efface le curseur texte }

begin
  gotoxy(x,y-lh+2);
  if length(T[y])<x then
     begin
       coulFond(GrisClair);
       coulTexte(GrisClair);
       write(graf,chr(219));
     end
                    else
     begin
       CoulFond(GrisClair);
       CoulTexte(GrisClair);
       write(graf,chr(219));
       gotoxy(x,y-lh+2);
       CoulTexte(Noir);
       write(graf,copy(T[Y],x,1));
     end;
end;



procedure Affiche_Ligne_Etat;
{ Affiche la ligne d'Çtat: nom du fichier, coordonnÇes et mÇmoire }

var st,st1,st2,st3:string;

begin
    if textemem then
        begin
            coulFond(Noir);
            coulTexte(Blanc);
            gotoxy(1,34);
            if modif then
                write(graf,'*')
                     else
                write(graf,' ');
        end;
    coulTexte(Bleu);
    gotoxy(1,2+nl);
    write(graf,lignevide);
    st:='    Fichier: '+nomfichier+'        ';
    str(x,st1);
    str(y,st2);
    if textemem then st:=st+'x= '+st1+'  y= '+st2
                else st:=st+'x= #   y= #';
    str(trunc((nfin/nmax)*100),st3);
    st:=st+'        MÇmoire utilisÇe: '+st3+'%';
    coulTexte(Jaune);
    coulFond(Bleu);
    gotoxy(1,2+nl);
    write(graf,st);
end;



function Lit_Clavier_Fictif:char;
{ Renvoie le caractäre frappÇ sur le clavier fictif }

var k,s:string;
    xs,ys,l,i:integer;

begin
  fonction:=false;
  k:=nul;
  l:=0;
  xs:=posSouris.x;
  ys:=posSouris.y;

  { DÇtermine quelle ligne a ÇtÇ frappÇe }
  for i:=1 to 5 do
    if (ys>=28*i+302) and (ys<=28*i+327) then l:=i;
  if l=1 then

    { Gestion de la premiäre ligne du clavier fictif }
    begin
      if shift then
          case langage of
              1: { clavier langue franáaise }
                 s:=chr(27)+'1234567890¯+';
              2: { clavier langue anglaise }
                 s:=chr(27)+'!"ú$%^&*()_+';
              3: { clavier langue allemande }
                 s:=chr(27)+'!"'+chr(21)+'$%&/()=?`';
          end
               else
          case langage of
              1: { clavier langue franáaise }
                 s:=chr(27)+'&Ç"'+chr(39)+'(-ä_áÖ)=';
              2: { clavier langue anglaise }
                 s:=chr(27)+'1234567890-=';
              3: { clavier langue allemande }
                 s:=chr(27)+'1234567890'+chr(225)+chr(239);
          end;
      for i:=1 to 13 do
        if (xs>=32*i-27) and (xs<=32*i+1) then k:=copy(s,i,1);
      if (xs>=421) and (xs<=481) then k:=chr(8);
    end
         else
    if l=2 then

      { Gestion deuxiäme ligne }
      begin
        if shift then
            case langage of
                1: { clavier langue franáaise }
                   s:='AZERTYUIOP~ú';
                2: { clavier langue anglaise }
                   s:='QWERTYUIOP{}';
                3: { clavier langue allemande }
                   s:='QWERTZUIOPö*';
            end
                 else
            case langage of
                1: { clavier langue franáaise }
                   s:='azertyuiop^$';
                2: { clavier langue anglaise }
                   s:='qwertyuiop[]';
                3: { clavier langue allemande }
                   s:='qwertzuiopÅ+';
            end;
        for i:=1 to 12 do
          if (xs>=32*i+21) and (xs<=32*i+49) then k:=copy(s,i,1);
        if (xs>=5) and (xs<=49) then k:=chr(9);
        if (xs>=437) and (xs<=481) then k:=rc;
        s:=chr(71)+chr(72)+chr(79)+chr(73);
        for i:=1 to 4 do
          if (xs>=32*i+477) and (xs<=32*i+537) then
            begin
              k:=copy(s,i,1);
              fonction:=true;
            end;
      end
           else
      if l=3 then

        { Gestion troisiäme ligne }
        begin
          if shift then
              case langage of
                  1: { clavier langue franáaise }
                     s:='QSDFGHJKLM%Ê';
                  2: { clavier langue anglaise }
                     s:='ASDFGHJKL:@~';
                  3: { clavier langue allemande }
                     s:='ASDFGHJKLôé'+chr(39);
              end
                   else
              case langage of
                  1: { clavier langue franáaise }
                     s:='qsdfghjklmó*';
                  2: { clavier langue anglaise }
                     s:='asdfghjkl;'+chr(39)+'#';
                  3: { clavier langue allemande }
                     s:='asdfghjklîÑ#';
              end;
          for i:=1 to 12 do
            if (xs>=32*i+37) and (xs<=32*i+65) then k:=copy(s,i,1);
          if (xs>=5) and (xs<=65) then
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
          if (xs>=453) and (xs<=481) then k:=rc;
          s:=chr(75)+chr(80)+chr(77)+chr(81);
          for i:=1 to 4 do
            if (xs>=32*i+477) and (xs<=32*i+537) then
              begin
                k:=copy(s,i,1);
                fonction:=true;
              end;
        end
             else
        if l=4 then

          { Gestion quatriäme ligne }
          begin
            if shift then
                case langage of
                    1: { clavier langue franáaise }
                       s:='>WXCVBN?./'+chr(21);
                    2: { clavier langue anglaise }
                       s:='|ZXCVBNM<>?';
                    3: { clavier langue allemande }
                       s:='>YXCVBNM;:_';
                end
                     else
                case langage of
                    1: { clavier langue franáaise }
                       s:='<wxcvbn,;:!';
                    2: { clavier langue anglaise }
                       s:='\zxcvbnm,./';
                    3: { clavier langue allemande }
                       s:='<yxcvbnm,.-';
                end;
            for i:=1 to 11 do
              if (xs>=32*i+21) and (xs<=32*i+49) then k:=copy(s,i,1);
            if ((xs>=5) and (xs<=49)) or ((xs>=405) and (xs<=481)) then
              begin
                if caps then caps:=false;
                shift:=not(shift);
                Dessine_Touches;
              end;
          end
               else
          if l=5 then

            { Gestion de la barre d'espacement }
            if (xs>=133) and (xs<=353) then k:=' ';
  if (k=nul) and (ys<14) then

    { Gestion des touches du menu }
    begin
      fonction:=true;
      if (xs>=17) and (xs<=103) then k:=chr(25);
      if (xs>=129) and (xs<=184) then k:=chr(49);
      if (xs>=209) and (xs<=265) then k:=chr(38);
      if (xs>=289) and (xs<=368) then k:=chr(31);
      if (xs>=394) and (xs<=473) then k:=chr(23);
      if (xs>=569) and (xs<=625) then k:=chr(16);
    end;

  if (k=nul) and ((ys>=14) and (ys<=293)) and textemem and not(input) then

    { Gestion du positionnement du curseur }
    begin
        Eteind_Curseur;
        x:=trunc(xs/8)+1;
        y:=lh+trunc(ys/14)-1;
        if x>length(t[y]) then x:=1+length(t[y]);
        if y>nfin then y:=nfin;
        Affiche_Curseur;
        Affiche_Ligne_Etat;
    end;

  if (k=nul) and ((ys>=440) and (ys<=453)) and not(input) then

    { Gestion du choix de la langue }
    begin
        cacheSouris;
        setcolor(Gris);
        Cadre_Drapeau(langage);
        if (xs>=520) and (xs<=543) then langage:=1;
        if (xs>=560) and (xs<=583) then langage:=2;
        if (xs>=600) and (xs<=623) then langage:=3;
        setcolor(Blanc);
        Cadre_Drapeau(langage);
        montreSouris;
        Dessine_Touches;
    end;
  if k<>nul then
    if shift and not(caps) then
      begin
        shift:=false;
        Dessine_Touches;
      end;
  Lit_Clavier_Fictif:=k[1];
end;



procedure Teste_Touche(var touche:char);
{ Attend qu'une touche soit frappÇe,sur le clavier physique ou fictif }

var car:char;
    vraiclavier:boolean;
    ch:string;
    h,m,s,s10:word;
    ss,sss:integer;

begin
  repeat
    vraiclavier:=false;
    fonction:=false;
    repeat
      execSouris;
      if Keypressed then vraiclavier:=true;
    until (boutSouris=1) or vraiclavier;
    if boutSouris=1 then
        begin
          touche:=Lit_Clavier_Fictif;
          if (pos(touche,touchesdepl)=0) and (touche<>del) and (touche<>tab) then
              begin
                  repeat
                      execSouris;
                  until boutSouris=0;
              end
                                       else
              begin
                  gettime(h,m,s,s10);
                  ss:=s10;
                  repeat
                      gettime(h,m,s,s10);
                      sss:=s10;
                  until (abs(ss-sss)>20);
              end;
        end
                    else
        begin
          touche:=readKey;
          if touche=nul then
            begin
               touche:=readKey;
               fonction:=true;
            end;
          while Keypressed do car:=readKey;
        end;

    if textemem then
        { Gestion de l'accent circonflexe et du trÇma }
        begin
            if (not(vraiclavier)) and (touche='^') and (langage=1) then
              begin
                Eteind_Curseur;
                Teste_Touche(touche);
                if pos(touche,'aeiou')<>0 then
                  begin
                    ch:='Éàåìñ';
                    touche:=ch[pos(touche,'aeiou')];
                  end
                                                                  else
                  begin
                    UnBip;
                    touche:='^';
                  end;
              end
                                                   else
              if (not(vraiclavier)) and (touche='~') and (langage=1) then
                begin
                  Eteind_Curseur;
                  Teste_Touche(touche);
                  if pos(touche,'aeiou')<>0 then
                    begin
                      ch:='ÑâãîÅ';
                      touche:=ch[pos(touche,'aeiou')];
                    end
                                                                    else
                    begin
                      UnBip;
                      touche:='~';
                    end;
                end;
        end;

    if textemem then
        { Gestion des accents sur le clavier allemand }
        begin
            if (not(vraiclavier)) and (touche='`') and (langage=3) then
              begin
                Eteind_Curseur;
                Teste_Touche(touche);
                if pos(touche,'aeiou')<>0 then
                  begin
                    ch:='Öä'+chr(141)+chr(149)+'ó';
                    touche:=ch[pos(touche,'aeiou')];
                  end
                                                                  else
                  begin
                    UnBip;
                    touche:='`';
                  end;
              end
                                                   else
              if (not(vraiclavier)) and (touche=chr(239)) and (langage=3) then
                begin
                  Eteind_Curseur;
                  Teste_Touche(touche);
                  if pos(touche,'aeiou')<>0 then
                    begin
                      ch:=chr(160)+'Ç'+chr(161)+chr(162)+chr(163);
                      touche:=ch[pos(touche,'aeiou')];
                    end
                                                                    else
                    begin
                      UnBip;
                      touche:=chr(39);
                    end;
                end;
        end;

  until touche<>nul;
end;



procedure Efface_Texte;
{ Efface le texte et remet toutes les variables Ö leur valeur par dÇfaut }

var i:integer;

begin
    for i:=1 to nmax do t[i]:='';
    textemem:=false;
    modif:=false;
    nfin:=1;
    x:=1;
    y:=1;
    lh:=1;
    nomfichier:='Inexistant';
end;



procedure Affiche_Texte(l1,l2,c,n:integer);
{ Affiche la fenàtre texte de la ligne l1 Ö la ligne l2}
{ n caractäres Ö partir de la colonne c }

var i:integer; touche:char;

begin
   for i:=l1 to l2 do
       begin
          coulTexte(GrisClair);
          gotoxy(c,i);
          write(graf,copy(lignevide,c,n));
          coulTexte(Noir);
          coulFond(GrisClair);
          gotoxy(c,i);
          write(graf,copy(t[lh+i-2],c,n));
       end;
end;



procedure Calcul_Fenetre;
{ DÇtermine les lignes devant àtre affichÇes suivant la position du curseur }

begin
    if y<lh then
        begin
            lh:=y;
            Affiche_Texte(2,nl+1,1,80);
        end
            else
        if y>lh+nl-1 then
            begin
                lh:=y-nl+1;
                Affiche_Texte(2,nl+1,1,80);
            end;
end;



procedure Affiche_Menu;
{ Affiche la barre de menu }

var st:string;

begin
    coulTexte(Bleu);
    gotoxy(1,1);
    write(graf,lignevide);
    coulTexte(Jaune);
    coulFond(Bleu);
    gotoxy(1,1);
    st:='  A_ ropos_de    ouveau    ecture    auvegarde    mpression';
    st:=st+'             uitter';
    write(graf,st);
    coulTexte(Orange);
    gotoxy(5,1);
    write(graf,'P');
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



procedure Avertissement(message:string);
{ Affiche un message d'avertissement sur la ligne d'Çtat }

var xx:integer;

begin
    coulTexte(Rouge);
    gotoxy(1,2+nl);
    write(graf,lignevide);
    xx:=trunc((80-length(message))/2);
    coulTexte(Jaune);
    coulFond(Rouge);
    gotoxy(xx,2+nl);
    write(graf,message);
    UnBip;
    Delay(1000);
end;


procedure Message(message:string);
{ Affiche un message d'information sur la ligne d'Çtat }

var xx:integer;

begin
    coulTexte(Bleu);
    gotoxy(1,2+nl);
    write(graf,lignevide);
    xx:=trunc((80-length(message))/2);
    coulTexte(Jaune);
    coulFond(Bleu);
    gotoxy(xx,2+nl);
    write(graf,message);
end;



procedure Dialogue(st:string;VAR reponse:boolean);
{ Ouvre une boåte de dialogue (OUI/NON) }

var touche,oui:char;
    i,xs,ys:integer;
    chaine,ch:string;
    vraiclavier:boolean;

begin
    chaine:='';
    for i:=1 to 42 do chaine:=chaine+chr(219);
    gotoxy(20,8);
    coulFond(Bleu);
    coulTexte(Bleu);
    for i:=0 to 4 do
        begin
            gotoxy(20,8+i);
            write(graf,chaine);
            inverseTexte(22,9+i,42);
        end;
    coulTexte(Jaune);
    gotoxy(1+trunc((80-length(st))/2),9);
    write(graf,st);
    coulFond(bleuClair);
    coulTexte(bleuClair);
    gotoxy(29,11);
    write(graf,copy(chaine,1,7));
    gotoxy(46,11);
    write(graf,copy(chaine,1,7));
    coulTexte(Noir);
    gotoxy(31,11);
    write(graf,'Oui');
    gotoxy(48,11);
    write(graf,'Non');
    coulFond(Bleu);
    coulTexte(Bleu);
    gotoxy(36,11);
    write(graf,chr(219));
    coulTexte(Noir);
    gotoxy(36,11);
    write(graf,chr(220));
    coulTexte(Bleu);
    gotoxy(53,11);
    write(graf,chr(219));
    coulTexte(Noir);
    gotoxy(53,11);
    write(graf,chr(220));
    ch:=chr(223)+chr(223)+chr(223)+chr(223)+chr(223)+chr(223)+chr(223);
    coulTexte(Bleu);
    gotoxy(30,12);
    write(graf,copy(chaine,1,7));
    coulTexte(Noir);
    gotoxy(30,12);
    write(graf,ch);
    coulTexte(Bleu);
    gotoxy(47,12);
    write(graf,copy(chaine,1,7));
    coulTexte(Noir);
    gotoxy(47,12);
    write(graf,ch);
    repeat
        vraiclavier:=false;
        touche:=nul;
        repeat
            execSouris;
            if Keypressed then vraiclavier:=true;
        until (boutSouris=1) or vraiclavier;
        if boutSouris=1 then
            begin
                xs:=posSouris.x;
                ys:=posSouris.y;
                if (ys>=140) and (ys<154) then
                    begin
                        if (xs>=224) and (xs<280) then
                            begin
                                touche:='O';
                                coulFond(Bleu);
                                coulTexte(Bleu);
                                gotoxy(29,11);
                                write(graf,chr(219));
                                coulFond(bleuClair);
                                coulTexte(bleuClair);
                                gotoxy(30,11);
                                write(graf,copy(chaine,1,7));
                                coulTexte(Noir);
                                gotoxy(32,11);
                                write(graf,'Oui');
                                coulTexte(Bleu);
                                gotoxy(30,12);
                                write(graf,copy(chaine,1,7));
                            end
                                                  else
                            if (xs>=360) and (xs<416) then
                              begin
                                touche:='N';
                                coulFond(Bleu);
                                coulTexte(Bleu);
                                gotoxy(46,11);
                                write(graf,chr(219));
                                coulFond(bleuClair);
                                coulTexte(bleuClair);
                                gotoxy(47,11);
                                write(graf,copy(chaine,1,7));
                                coulTexte(Noir);
                                gotoxy(49,11);
                                write(graf,'Non');
                                coulTexte(Bleu);
                                gotoxy(47,12);
                                write(graf,copy(chaine,1,7));
                              end;
                        repeat
                            execSouris;
                        until (boutSouris=0);
                    end;
            end
                        else
            touche:=Upcase(readkey);
    until (touche='O') or (touche='N');
    if touche='O' then reponse:=true
                  else reponse:=false;
    coulFond(grisClair);
    Affiche_Texte(8,13,20,44);
end;



procedure Warning(st:string);
{ Ouvre une boåte d'avertissement }

var chaine,ch:string;
    i,xs,ys:integer;
    touche:char;
    vraiclavier:boolean;

begin
    chaine:='';
    for i:=1 to 42 do chaine:=chaine+chr(219);
    gotoxy(20,8);
    coulFond(Bleu);
    coulTexte(Bleu);
    for i:=0 to 4 do
        begin
            gotoxy(20,8+i);
            write(graf,chaine);
            inverseTexte(22,9+i,42);
        end;
    coulTexte(Jaune);
    gotoxy(1+trunc((80-length(st))/2),9);
    write(graf,st);
    gotoxy(38,11);
    coulFond(bleuClair);
    coulTexte(bleuClair);
    write(graf,copy(chaine,1,6));
    gotoxy(40,11);
    coulTexte(Noir);
    write(graf,'Ok');
    coulFond(Bleu);
    coulTexte(Bleu);
    gotoxy(44,11);
    write(graf,chr(219));
    coulTexte(Noir);
    gotoxy(44,11);
    write(graf,chr(220));
    ch:=chr(223)+chr(223)+chr(223)+chr(223)+chr(223)+chr(223);
    coulTexte(Bleu);
    gotoxy(39,12);
    write(graf,copy(chaine,1,6));
    coulTexte(Noir);
    gotoxy(39,12);
    write(graf,ch);
    repeat
        vraiclavier:=false;
        touche:=nul;
        repeat
            execSouris;
            if Keypressed then vraiclavier:=true;
        until (boutSouris=1) or vraiclavier;
        if boutSouris=1 then
            begin
                xs:=posSouris.x;
                ys:=posSouris.y;
                if (ys>=140) and (ys<154) and (xs>=296) and (xs<344) then
                    begin
                        touche:=rc;
                        coulFond(Bleu);
                        coulTexte(Bleu);
                        gotoxy(38,11);
                        write(graf,chr(219));
                        coulFond(bleuClair);
                        coulTexte(bleuClair);
                        gotoxy(39,11);
                        write(graf,copy(chaine,1,6));
                        coulTexte(Noir);
                        gotoxy(41,11);
                        write(graf,'Ok');
                        coulTexte(Bleu);
                        gotoxy(39,12);
                        write(graf,copy(chaine,1,6));
                    end;
                repeat
                    execSouris;
                until (boutSouris=0);
            end
                        else
            touche:=readkey;
    until touche=rc;
    Affiche_Texte(8,13,20,44);
end;



function Entre_Nom(st:string):string;
{ Permet l'entrÇe d'un nom de fichier au clavier (fictif ou physique) }

var chaine,nomfichier:string;
    car:char;i,x0,s:integer;
    annul:boolean;

begin
  input:=true;
  annul:=false;
  chaine:='';
  for i:=1 to 42 do chaine:=chaine+chr(219);
  gotoxy(20,8);
  CoulFond(Bleu);
  CoulTexte(Bleu);
  for i:=0 to 4 do
     begin
       gotoxy(20,8+i);
       write(graf,chaine);
       inverseTexte(22,9+i,42);
     end;
  CoulTexte(Jaune);
  gotoxy(trunc((80-length(st))/2),9);
  write(graf,st);
  CoulFond(GrisClair);
  CoulTexte(GrisClair);
  gotoxy(36,11);
  write(graf,copy(chaine,1,9));
  nomfichier:='';
  x0:=36;
  repeat
       gotoxy(x0,11);
       coulFond(Noir);
       coulTexte(Noir);
       write(graf,chr(219));
       Teste_Touche(car);
       if car=chr(27) then annul:=true;
       if (((car>='0') and (car<='9')) or ((car>='A') and (car<='Z')) or ((car>='a') and (car<='z'))) and not(fonction) then
        begin
         if x0<44 then
          begin
           nomfichier:=nomfichier+car;
           gotoxy(x0,11);
           coulFond(GrisClair);
           coulTexte(GrisClair);
           write(graf,chr(219));
           gotoxy(x0,11);
           coulTexte(Noir);
           write(graf,car);
           x0:=x0+1;
          end
                  else
          unBip;
        end
                          else
         begin
           if car=del then
            if x0>36 then
             begin
               gotoxy(x0,11);
               coulFond(GrisClair);
               coulTexte(GrisClair);
               write(graf,chr(219));
               nomfichier:=copy(nomfichier,1,length(nomfichier)-1);
               x0:=x0-1;
               gotoxy(x0,11);
               write(graf,chr(219));
             end
                     else
            unBip;
         end;
  until (car=rc) or annul;
  if annul then nomfichier:='';
  coulFond(GrisClair);
  coulTexte(GrisClair);
  gotoxy(x0,11);
  write(graf,chr(219));
  Affiche_Texte(8,13,20,44);
  input:=false;
  nomfichier:=majuscule(nomfichier);
  Entre_Nom:=nomfichier;
end;



procedure Deplacements(touche:char);
{ Gäre les dÇplacements du curseur }

var comm:integer;

begin
    comm:=pos(touche,touchesdepl);
    case comm of
        1: { DÇplacement vers la gauche }
           begin
               if x>1 then x:=x-1
                      else if y>1 then
                               begin
                                   y:=y-1;
                                   if length(t[y])<80 then x:=length(t[y])+1
                                                      else x:=80;
                               end
                                  else
                               Avertissement('Haut Document');
           end;
        2: { DÇplacement vers la droite }
           begin
               if length(t[y])<80 then
                 begin
                   if x<=length(t[y]) then x:=x+1
                                      else if y<nfin then
                                              begin
                                                  y:=y+1;
                                                  x:=1;
                                              end
                                                     else
                                              Avertissement('Bas Document');
                 end
                                  else
                 begin
                     if x<length(t[y]) then x:=x+1
                                       else if y<nfin then
                                               begin
                                                   y:=y+1;
                                                   x:=1;
                                               end
                                                      else
                                               Avertissement('Bas Document');
                 end;
           end;
        3: { DÇplacement vers le haut }
           begin
               if y>1 then
                   begin
                       y:=y-1;
                       if x>length(t[y]) then x:=length(t[y])+1;
                   end
                      else
                   Avertissement('Haut Document');
           end;
        4: { DÇplacement vers le bas }
           begin
               if y<nfin then
                   begin
                       y:=y+1;
                       if x>length(t[y]) then x:=length(t[y])+1;
                   end
                         else
                   Avertissement('Bas Document');
           end;
        5: { DÇplacement d'une page vers le haut (PgUp) }
           begin
               y:=y-nl;
               if y<1 then
                   begin
                       y:=1;
                       Avertissement('Haut Document');
                   end
                      else
                   if x>length(t[y]) then x:=length(t[y])+1;
           end;
        6: { DÇplacement d'une page vers le bas (PgDwn) }
           begin
               y:=y+nl;
               if y>nfin then
                   begin
                       y:=nfin;
                       Avertissement('Bas Document');
                   end
                         else
                   if x>length(t[y]) then x:=length(t[y])+1;
           end;
        7: { Place le curseur au dÇbut du texte (Home) }
           begin
               x:=1;
               y:=1;
           end;
        8: { Place le curseur Ö la fin du texte (Bottom) }
           begin
               y:=nfin;
               if length(t[y])<80 then x:=length(t[y])+1
                                  else x:=80;
           end;
    end;
    Calcul_Fenetre;
end;



procedure A_Propos;
{ Affiche le numÇro de version du logiciel }

var chaine,ch:string;
    i,xs,ys:integer;
    touche:char;
    vraiclavier:boolean;

begin
    chaine:='';
    for i:=1 to 44 do chaine:=chaine+chr(219);
    coulFond(Noir);
    coulTexte(Noir);
    gotoxy(2,1);
    write(graf,copy(chaine,1,13));
    CoulTexte(Blanc);
    gotoxy(2,1);
    write(graf,' A_Propos_de ');
    coulFond(Bleu);
    coulTexte(Bleu);
    for i:=0 to 8 do
        begin
            gotoxy(18,7+i);
            write(graf,chaine);
            inverseTexte(20,8+i,44);
        end;
    coulTexte(Blanc);
    gotoxy(20,10);
    write(graf,'Un Çditeur de textes pilotÇ Ö la souris');
    gotoxy(25,12);
    write(graf,'par PEYROT Bruno (16/08/1994)');
    coulFond(Noir);
    coulTexte(Noir);
    gotoxy(32,8);
    write(graf,copy(chaine,1,16));
    coulTexte(Blanc);
    gotoxy(32,8);
    write(graf,'MouseWriter v2.0');
    coulFond(bleuClair);
    coulTexte(bleuClair);
    gotoxy(37,14);
    write(graf,copy(chaine,1,6));
    gotoxy(39,14);
    coulTexte(Noir);
    write(graf,'Vu');
    coulFond(Bleu);
    coulTexte(Bleu);
    gotoxy(43,14);
    write(graf,chr(219));
    coulTexte(Noir);
    gotoxy(43,14);
    write(graf,chr(220));
    ch:=chr(223)+chr(223)+chr(223)+chr(223)+chr(223)+chr(223);
    coulTexte(Bleu);
    gotoxy(38,15);
    write(graf,copy(chaine,1,6));
    coulTexte(Noir);
    gotoxy(38,15);
    write(graf,ch);
    repeat
        vraiclavier:=false;
        touche:=nul;
        repeat
            execSouris;
            if Keypressed then vraiclavier:=true;
        until (boutSouris=1) or vraiclavier;
        if boutSouris=1 then
            begin
                xs:=posSouris.x;
                ys:=posSouris.y;
                if (ys>=182) and (ys<196) and (xs>=288) and (xs<336) then
                    begin
                        touche:=rc;
                        coulFond(Bleu);
                        coulTexte(Bleu);
                        gotoxy(37,14);
                        write(graf,chr(219));
                        coulFond(bleuClair);
                        coulTexte(bleuClair);
                        gotoxy(38,14);
                        write(graf,copy(chaine,1,6));
                        coulTexte(Noir);
                        gotoxy(40,14);
                        write(graf,'Vu');
                        coulTexte(Bleu);
                        gotoxy(38,15);
                        write(graf,copy(chaine,1,6));
                    end;
                repeat
                    execSouris;
                until (boutSouris=0);
            end
                        else
            touche:=readkey;
    until touche=rc;
    Affiche_Texte(7,16,18,46);
end;



procedure Save(fichiersauv:string);
{ Transforme le texte en mÇmoire en fichier Ascii et le sauvegarde }

var fichier:text;
    l,c:integer;
    ok:boolean;

begin
  changeCurseur(ptrSablier);
  Message('Sauvegarde de '+fichiersauv+'...');
  assign(fichier,fichiersauv);
  {$I-}
  rewrite(fichier);
  {$I+}
  ok:=IoResult=0;
  if ok then
    begin
      for l:=1 to nfin do
        begin
          for c:=1 to length(T[l]) do write(fichier,copy(T[l],c,1));
          write(fichier,rc);
          if l<>nfin then write(fichier,chr(10));
        end;
      close(fichier);
      modif:=false;
      changeCurseur(ptrFleche);
    end
        else
    begin
        changeCurseur(ptrFleche);
        Warning('Erreur d''Çcriture');
    end;
end;



procedure Sauvegarde;
{ Sauvegarde le texte }
var reponse:boolean;
    st,fichiersauv:string;
    i:integer;

begin
  st:='';
  for i:=1 to 12 do st:=st+chr(219);
  coulFond(Noir);
  coulTexte(Noir);
  gotoxy(36,1);
  write(graf,st);
  coulTexte(Blanc);
  gotoxy(36,1);
  write(graf,' Sauvegarde ');
  if textemem then
    begin
     st:='Voulez-vous vraiment sauvegarder ?';
     Dialogue(st,reponse);
     if reponse then
     begin
      st:='Voulez-vous changer le nom ?';
      Dialogue(st,reponse);
      if not(reponse) then Save(nomfichier)
                      else
        begin
          st:='Nom de sauvegarde ? (ESC annule)';
          fichiersauv:=Entre_Nom(st);
          if fichiersauv<>'' then
            begin
              fichiersauv:=fichiersauv+'.MWT';
              if ficExiste(fichiersauv) then
                  begin
                      st:=fichiersauv+' existe dÇjÖ. Ecrasement ?';
                      Dialogue(st,reponse);
                      if reponse then
                          begin
                              Save(fichiersauv);
                              nomfichier:=fichiersauv;
                          end;
                  end
                                        else
                  begin
                      Save(fichiersauv);
                      nomfichier:=fichiersauv;
                  end;
            end;
        end;
     end;
    end
              else
    Warning('Il n''y a aucun texte en mÇmoire');
end;



procedure Nouveau;
{ Ouvre un nouveau texte }

var st,fichier:string;
    reponse:boolean;
    i:integer;

begin
  st:='';
  for i:=1 to 9 do st:=st+chr(219);
  coulFond(Noir);
  coulTexte(Noir);
  gotoxy(16,1);
  write(graf,st);
  coulTexte(Blanc);
  gotoxy(16,1);
  write(graf,' Nouveau ');
  if textemem and modif then
     begin
       st:=nomfichier+' a ÇtÇ modifiÇ. Sauvegarde ?';
       Dialogue(st,reponse);
       if reponse then Save(nomfichier);
     end;
  st:='Nom du texte ? (ESC annule)';
  fichier:=Entre_Nom(st);
  if fichier<>'' then
      begin
          Efface_Texte;
          nomfichier:=fichier+'.MWT';
          textemem:=true;
          Affiche_Texte(2,nl+1,1,80);
      end;
end;



procedure Load(fichierlec:string);
{ Lit un texte en ASCII et le convertit au format MouseWriter }

var ok,ras:boolean;
    fichier:text;
    l:integer;ch:char;

begin
    changeCurseur(ptrSablier);
    Message('Lecture de '+fichierlec+'...');
    assign(fichier,fichierlec);
    {$I-}
    reset(fichier);
    {$I+}
    ok:=IoResult=0;
    if ok then
        begin
            Efface_Texte;
            l:=1;
            ras:=true;
            while not(eof(fichier)) and ras do
                begin
                    read(fichier,ch);
                    if ch<>rc then T[l]:=T[l]+ch
                              else
                        begin
                            read(fichier,ch);
                            l:=l+1;
                            if l>nmax then
                                begin
                                    changeCurseur(ptrFleche);
                                    l:=nmax;
                                    Warning('Texte trop long. Je coupe.');
                                    ras:=false;
                                end;
                        end;
                end;
            close(fichier);
            changeCurseur(ptrFleche);
            textemem:=true;
            modif:=false;
            nomfichier:=fichierlec;
            nfin:=l;
            Affiche_Texte(2,nl+1,1,80);
        end
          else
        begin
            changeCurseur(ptrFleche);
            Warning('Erreur de lecture');
        end;
end;



procedure Lecture;
{ Lit un fichier texte .MWT }

var fichiers:array[1..200] of string[12];
    bouton:array[1..4] of string[6];
    repertoire:searchrec;
    c,l,f,i,j,nbfichiers,nbpages,page,xc,yc,xs,ys,col,lig:integer;
    ch,chaine,fichierlec,temp,st,st1,st2:string;
    fini1,fini2,vraiclavier,reponse:boolean;
    touche:char;

begin
    st:='';
    for i:=1 to 9 do st:=st+chr(219);
    coulFond(Noir);
    coulTexte(Noir);
    gotoxy(26,1);
    write(graf,st);
    coulTexte(Blanc);
    gotoxy(26,1);
    write(graf,' Lecture ');
    if textemem and modif then
        begin
            st:=nomfichier+' a ÇtÇ modifiÇ. Sauvegarde ?';
            Dialogue(st,reponse);
            if reponse then Save(nomfichier);
        end;

    { Lecture du rÇpertoire courant }
    for i:=1 to 200 do fichiers[i]:='';
    i:=0;
    findfirst('*.MWT',archive,repertoire);
    while (doserror=0) and (i<200) do
        begin
            i:=i+1;
            fichiers[i]:=copy(repertoire.name,1,pos('.',repertoire.name)-1);
            while length(fichiers[i])<8 do fichiers[i]:=fichiers[i]+' ';
            fichiers[i]:=fichiers[i]+'.MWT';
            findnext(repertoire);
        end;
    nbfichiers:=i;

    { Tri alphabÇtique des fichiers }
    if nbfichiers>1 then
        begin
            for i:=1 to (nbfichiers-1) do
                for j:=i+1 to nbfichiers do
                    if fichiers[j]<fichiers[i] then
                        begin
                            temp:=fichiers[j];
                            fichiers[j]:=fichiers[i];
                            fichiers[i]:=temp;
                        end;
        end;

    if nbfichiers>0 then
    begin
    chaine:='';
    for i:=1 to 53 do chaine:=chaine+chr(219);
    coulFond(Bleu);
    coulTexte(Bleu);
    for i:=5 to 18 do
        begin
            gotoxy(14,i);
            write(graf,chaine);
            inverseTexte(16,i+1,53);
        end;
    coulTexte(Jaune);
    gotoxy(16,6);
    write(graf,'RÇpertoire: '+repPrg+'*.MWT');
    gotoxy(58,16);
    write(graf,'Page:');
    chaine:=copy(chaine,1,40);
    nbpages:=trunc(nbfichiers/24)+1;
    page:=1;
    fini1:=false;
    repeat
        bouton[1]:='  Ok';
        bouton[2]:='Annule';
        bouton[3]:='  '+chr(24)+chr(24);
        bouton[4]:='  '+chr(25)+chr(25);
        for i:=1 to 4 do
            begin
                coulFond(bleuClair);
                coulTexte(bleuClair);
                gotoxy(58,2*i+6);
                write(graf,copy(chaine,1,6));
                coulTexte(Noir);
                gotoxy(58,2*i+6);
                write(graf,bouton[i]);
                coulFond(Bleu);
                coulTexte(Bleu);
                gotoxy(64,2*i+6);
                write(graf,chr(219));
                coulTexte(Noir);
                gotoxy(64,2*i+6);
                write(graf,chr(220));
                ch:=chr(223)+chr(223)+chr(223)+chr(223)+chr(223)+chr(223);
                coulTexte(Bleu);
                gotoxy(59,2*i+7);
                write(graf,copy(chaine,1,6));
                coulTexte(Noir);
                gotoxy(59,2*i+7);
                write(graf,ch);
            end;
        xc:=1;
        yc:=1;
        str(page,st1);
        str(nbpages,st2);
        coulFond(Bleu);
        coulTexte(Bleu);
        gotoxy(61,17);
        write(graf,copy(chaine,1,6));
        coulTexte(Jaune);
        gotoxy(61,17);
        write(graf,st1+'/'+st2);
        coulFond(grisClair);
        coulTexte(grisClair);
        for i:=8 to 17 do
            begin
                gotoxy(16,i);
                write(graf,chaine);
            end;
        coulTexte(Noir);
        for c:=1 to 3 do
          begin
            for l:=1 to 8 do
                begin
                    f:=l+(c-1)*8+(page-1)*24;
                    if f<=nbfichiers then
                        begin
                            gotoxy(13*c+4,l+8);
                            write(graf,fichiers[f]);
                        end;
                end;
          end;
        fini2:=false;
        repeat
            vraiclavier:=false;
            coulFond(Noir);
            coulTexte(Noir);
            gotoxy(13*xc+4,yc+8);
            write(graf,copy(chaine,1,12));
            coulTexte(Blanc);
            gotoxy(13*xc+4,yc+8);
            write(graf,fichiers[yc+(xc-1)*8+(page-1)*24]);
            repeat
                execSouris;
                if keypressed then vraiclavier:=true;
            until (boutSouris=1) or vraiclavier;
            coulFond(grisClair);
            coulTexte(grisClair);
            gotoxy(13*xc+4,yc+8);
            write(graf,copy(chaine,1,12));
            coulTexte(Noir);
            gotoxy(13*xc+4,yc+8);
            write(graf,fichiers[yc+(xc-1)*8+(page-1)*24]);
            if boutSouris=1 then
                begin
                    xs:=posSouris.x;
                    ys:=posSouris.y;
                    if (ys>=98) and (ys<224) then
                        begin
                            if (xs>=128) and (xs<224) then col:=1;
                            if (xs>=232) and (xs<328) then col:=2;
                            if (xs>=336) and (xs<432) then col:=3;
                            lig:=trunc(ys/14)-7;
                            if (xs>=456) and (xs<504) then
                                case lig of
                                    0: { bouton OK }
                                       begin
                                           f:=yc+(xc-1)*8+(page-1)*24;
                                           fichierlec:=fichiers[f];
                                           fini1:=true;
                                           fini2:=true;
                                       end;
                                    2: { bouton ANNULE }
                                       begin
                                           fichierlec:='';
                                           fini1:=true;
                                           fini2:=true;
                                       end;
                                    4: { bouton PgUp }
                                       begin
                                           if page>1 then
                                               begin
                                                   page:=page-1;
                                                   fini2:=true;
                                               end
                                                     else
                                               begin
                                                   unBip;
                                                   fini2:=true;
                                               end;
                                       end;
                                    6: { bouton PgDwn }
                                       begin
                                           if page<nbpages then
                                               begin
                                                   page:=page+1;
                                                   fini2:=true;
                                               end
                                                           else
                                               begin
                                                   unBip;
                                                   fini2:=true;
                                               end;
                                       end;
                                end
                                                      else
                                if (lig>0) and (lig<9) then
                                    begin
                                        f:=lig+(col-1)*8+(page-1)*24;
                                        if f<=nbfichiers then
                                            begin
                                                xc:=col;
                                                yc:=lig;
                                            end;
                                        repeat
                                            execSouris;
                                        until (boutSouris=0);
                                    end;
                        end;
                end
                            else
                begin
                    touche:=readkey;
                    if (pos(touche,touchesdepl)<>0) then
                        begin
                            col:=xc;
                            lig:=yc;
                            case pos(touche,touchesdepl) of
                                1: { Gauche }
                                   if xc>1 then col:=xc-1;
                                2: { Droite }
                                   if xc<3 then col:=xc+1;
                                3: { Haut }
                                   if yc>1 then lig:=yc-1;
                                4: { Bas }
                                   if yc<8 then lig:=yc+1;
                                5: { PgUp }
                                   begin
                                       if page>1 then page:=page-1
                                                 else unBip;
                                       fini2:=true;
                                   end;
                                6: { PgDwn }
                                   begin
                                       if page<nbpages then page:=page+1
                                                       else unBip;
                                       fini2:=true;
                                   end;
                            end;
                            f:=lig+(col-1)*8+(page-1)*24;
                            if f<=nbfichiers then
                                begin
                                    xc:=col;
                                    yc:=lig;
                                end;
                        end;
                    if (touche=chr(27)) then
                        begin
                            fichierlec:='';
                            fini1:=true;
                            fini2:=true;
                        end;
                    if (touche=rc) then
                        begin
                            f:=yc+(xc-1)*8+(page-1)*24;
                            fichierlec:=fichiers[f];
                            fini1:=true;
                            fini2:=true;
                        end;
                end;
        until fini2;
        if (boutSouris=1) then
            begin
                i:=((lig+1) div 2)+1;
                coulFond(Bleu);
                coulTexte(Bleu);
                gotoxy(58,2*i+6);
                write(graf,chr(219));
                coulFond(bleuClair);
                coulTexte(bleuClair);
                gotoxy(59,2*i+6);
                write(graf,copy(chaine,1,6));
                coulTexte(Noir);
                gotoxy(59,2*i+6);
                write(graf,bouton[i]);
                coulTexte(Bleu);
                gotoxy(59,2*i+7);
                write(graf,copy(chaine,1,6));
                repeat
                    execSouris;
                until (boutSouris=0);
            end;
    until fini1;
    Affiche_Texte(5,19,14,55);
    if fichierlec<>'' then
        begin
            if (pos(' ',fichierlec)<>0) then
                fichierlec:=copy(fichierlec,1,pos(' ',fichierlec)-1)+'.MWT';
            Load(fichierlec);
        end;
    end
                    else
    Warning('Aucun fichier MouseWriter disponible');
end;



procedure Impression;
{ Imprime le texte en mÇmoire }

var imprimanteok,reponse:boolean;
    nbpages,i,j,l:integer;
    st,st1,st2,st3:string;

begin
 st:='';
 for i:=1 to 12 do st:=st+chr(219);
 coulFond(Noir);
 coulTexte(Noir);
 gotoxy(49,1);
 write(graf,st);
 coulTexte(Blanc);
 gotoxy(49,1);
 write(graf,' Impression ');
 if textemem then
   begin
    imprimanteok:=ImprimantePrete;
    if imprimanteok then
        begin
            st:='Voulez-vous vraiment imprimer ?';
            Dialogue(st,reponse);
            if reponse then
                begin
                    Warning('Positionnez le papier...');
                    changeCurseur(ptrSablier);
                    nbpages:=trunc(nfin/56)+1;
                    for i:=1 to nbpages do
                        begin
                            str(i,st2);
                            str(nbpages,st3);
                            st1:='Impression de '+nomfichier+' en cours...';
                            st1:=st1+'  (page '+st2+'/'+st3+')';
                            Message(st1);
                            for j:=1 to 3 do writeln(Lst,' ');
                            for l:=1 to 56 do
                            if (l+56*(i-1)<=nfin) then writeln(Lst,t[l+56*(i-1)])
                                                  else writeln(Lst,' ');
                            writeln(Lst,' ');
                            writeln(Lst,' ');
                            writeln(Lst,'                                     - ',i,' -');
                            for j:=1 to 4 do writeln(Lst,' ');
                         end;
                    changeCurseur(ptrFleche);
                end;
        end
                    else
        begin
            UnBip;
            Warning('L''imprimante n''est pas pràte');
        end;
   end
             else
   Warning('Il n''y a aucun texte en mÇmoire');
end;



procedure Quitter;
{ Au revoir... }

var st:string;
    reponse:boolean;
    i:integer;

begin
  st:='';
  for i:=1 to 9 do st:=st+chr(219);
  coulFond(Noir);
  coulTexte(Noir);
  gotoxy(71,1);
  write(graf,st);
  coulTexte(Blanc);
  gotoxy(71,1);
  write(graf,' Quitter ');
  if textemem and modif then
      begin
          st:=nomfichier+' a ÇtÇ modifiÇ. Sauvegarde ?';
          Dialogue(st,reponse);
          if reponse then Save(nomfichier);
      end;
  st:='Etes-vous sñr de vouloir quitter ?';
  Dialogue(st,reponse);
  if reponse then fini:=true;
end;


procedure Fonctions(touche:char);
{ Gäre les diffÇrentes fonctions du programme }

var comm:integer;

begin
    comm:=pos(touche,touchesfonc);
    case comm of
        1: A_Propos;
        2: Nouveau;
        3: Lecture;
        4: Sauvegarde;
        5: Impression;
        6: Quitter;
        7..9: begin
                  {Gestion du choix de la langue }
                  cacheSouris;
                  setcolor(gris);
                  Cadre_Drapeau(langage);
                  if comm=7 then langage:=1;
                  if comm=8 then langage:=2;
                  if comm=9 then langage:=3;
                  setcolor(blanc);
                  Cadre_Drapeau(langage);
                  montreSouris;
                  Dessine_Touches;
              end;
    end;
    if not(fini) then Affiche_Menu;
end;



function Trouve_Blanc_Fin(st:string):integer;
{ Trouve le premier espace d'une chaåne en partant de la fin }

var i:integer;

begin
    i:=length(st)+1;
    repeat
        i:=i-1;
    until ((copy(st,i,1)=' ') or (i=1));
    if copy(st,i,1)<>' ' then i:=length(st)+1;
    Trouve_Blanc_Fin:=i;
end;



procedure Nettoie(var chaine:string);
{ Enläve les espaces se trouvant Ö la fin d'une chaine }

begin
    while Trouve_Blanc_Fin(chaine)=length(chaine) do
        chaine:=copy(chaine,1,length(chaine)-1);
end;



procedure Justifie(ligne:integer);
{ Justifie la ligne numÇro 'ligne' }

var i,j,k,l,xb,nmot,nlettre:integer;
    mot,blank:array[1..40] of string[80];
    ch,chaine:string;
    a:char;

begin

    { DÇcoupe la ligne en diffÇrents mots }
    l:=length(t[ligne]);
    i:=0;
    repeat
        i:=i+1;
    until ((copy(t[ligne],i,1)<>' ') or (i=l));
    if i<l then
        begin
            repeat
                i:=i+1;
            until((copy(t[ligne],i,1)=' ') or (i=l));
            if i<l then
                begin
                    if (x<=i+1) and (y=ligne) then
                        begin
                            nmot:=1;
                            nlettre:=x;
                        end;
                    mot[1]:=copy(t[ligne],1,i-1);
                    chaine:=mot[1];
                    Nettoie(chaine);
                    mot[1]:=chaine;
                    k:=1;
                    while i<l do
                        begin
                            j:=0;
                            repeat
                                i:=i+1;
                            until((copy(t[ligne],i,1)<>' ') or (i=l));
                            if i<l then
                                begin
                                    j:=i;
                                    repeat
                                        i:=i+1;
                                    until((copy(t[ligne],i,1)=' ') or (i=l));
                                    k:=k+1;
                                    if (x>=j) and (x<=i+1) and (y=ligne) then
                                        begin
                                            nmot:=k;
                                            nlettre:=x-j+1;
                                        end;
                                    if i=l then
                                      begin
                                        mot[k]:=copy(t[ligne],j,i-j+1);
                                        chaine:=mot[k];
                                        Nettoie(chaine);
                                        mot[k]:=chaine;
                                      end
                                           else
                                      begin
                                        mot[k]:=copy(t[ligne],j,i-j);
                                        chaine:=mot[k];
                                        Nettoie(chaine);
                                        mot[k]:=chaine;
                                      end;
                                end;
                        end;

                    { DÇtermine les espacements convenables entre les mots }
                    l:=0;
                    for i:=1 to k do l:=l+length(mot[i]);
                    l:=80-l;
                    if k>1 then
                      begin
                        for i:=1 to (k-1) do
                            begin
                                blank[i]:='';
                                for j:=1 to trunc(l/(k-1)) do
                                    blank[i]:=blank[i]+' ';
                            end;
                        l:=l-trunc(l/(k-1))*(k-1);
                        for i:=1 to l do blank[i]:=blank[i]+' ';
                        t[ligne]:='';

                        { On recolle les morceaux }
                        for i:=1 to (k-1) do
                                t[ligne]:=t[ligne]+mot[i]+blank[i];
                        t[ligne]:=t[ligne]+mot[k];
                        if y=ligne then
                          begin
                            x:=0;
                            if nmot>1 then
                              begin
                                for i:=1 to (nmot-1) do
                                  begin
                                    x:=x+length(mot[i])+length(blank[i]);
                                  end;
                                x:=x+nlettre+1;
                                if (x>80) then x:=80;
                                if (x<1) then x:=1;
                              end
                                      else
                              x:=nlettre+1;
                          end;
                        end
                                   else
                          t[ligne]:=mot[k];
                end;
        end;
end;



procedure Decale_lignes(ligne:integer;chaine:string);
{ DÇcale toutes les lignes vers le bas lors de l'insertion d'un mot }

var i,j,k,xblanc:integer;
    mot:array[1..40] of string;

begin
    while length(chaine)>80 do
        begin
            i:=1;
            while length(chaine)>80 do
                begin
                    Nettoie(chaine);
                    xblanc:=Trouve_Blanc_Fin(chaine);
                    mot[i]:=copy(chaine,xblanc+1,length(chaine)-xblanc);
                    Nettoie(mot[i]);
                    chaine:=copy(chaine,1,xblanc-1);
                    i:=i+1;
                end;
            i:=i-1;
            t[ligne]:=chaine;
            Justifie(ligne);
            ligne:=ligne+1;
            if t[ligne]='' then
                begin
                    for j:=nfin downto ligne do t[j+1]:=t[j];
                    nfin:=nfin+1;
                end;
            chaine:='';
            for k:=i downto 1 do chaine:=chaine+mot[k]+' ';
            chaine:=chaine+t[ligne];
        end;
    Nettoie(chaine);
    t[ligne]:=chaine;
end;



procedure Insere_Caractere(touche:char);
{ Insäre un caractäre Ö la position courante du curseur }

var chaine,motfin:string;
    mot:array[1..40] of string[80];
    xblanc,ligne:integer;

begin
    modif:=true;

    { On insäre dans une ligne incompläte... }
    if length(t[y])<79 then
      begin

        { ...Ö la fin de la ligne }
        if (x=length(t[y])+1) then
          begin
            t[y]:=t[y]+touche;
            coulFond(GrisClair);
            coulTexte(GrisClair);
            gotoxy(x,y-lh+2);
            write(graf,chr(219));
            coulTexte(Noir);
            gotoxy(x,y-lh+2);
            write(graf,copy(t[y],x,1));
          end
                              else

          { ...au milieu de la ligne }
          begin
            t[y]:=copy(t[y],1,x-1)+touche+copy(t[y],x,length(t[y])-x+1);
            coulFond(GrisClair);
            coulTexte(GrisClair);
            gotoxy(1,y-lh+2);
            write(graf,lignevide);
            coulTexte(Noir);
            gotoxy(1,y-lh+2);
            write(graf,t[y]);
          end;
          x:=x+1;
          if x>80 then
            begin
              x:=1;
              y:=y+1;
            end;
      end
                        else

      { On insäre dans une ligne remplie: nÇcessitÇ d'une rejustification }
      if nfin<nmax then
        begin
          if x<length(t[y])+1 then
             chaine:=copy(t[y],1,x-1)+touche+copy(t[y],x,length(t[y])-x+1)
                              else
             chaine:=t[y]+touche;
          Nettoie(chaine);
          xblanc:=Trouve_Blanc_Fin(chaine);
          motfin:=copy(chaine,xblanc+1,length(chaine)-xblanc);
          Nettoie(motfin);
          ligne:=y;
          if x>xblanc then
            begin
              y:=y+1;
              x:=x-xblanc+1;
            end;
          t[ligne]:=copy(chaine,1,xblanc-1);
          chaine:=t[ligne];
          Nettoie(chaine);
          Justifie(ligne);
          chaine:=motfin+' '+t[ligne+1];
          Decale_lignes(ligne+1,chaine);
          if touche=' ' then t[y]:=t[y]+' ';
          if y>lh+nl-1 then Calcul_Fenetre
                       else Affiche_Texte(2,nl+1,1,80);
          if x>length(t[y])+1 then x:=length(t[y])+1;
          if nfin<y then nfin:=y;
        end
                   else
        Avertissement('Document plein: insertion impossible');
end;



procedure Gestion_Touche_Del;
{ Gäre le comportement de la touche Delete }

var i:integer;
    chaine:string;

begin
  modif:=true;
  if t[y]<>'' then
    begin
     if x=length(t[y])+1 then
      begin
        t[y]:=copy(t[y],1,length(t[y])-1);
        x:=x-1;
        coulTexte(Noir);
        gotoxy(x,y-lh+2);
        write(graf,chr(219));
      end
                        else
      if x>1 then
        begin
          if x=2 then
            begin
              t[y]:=copy(t[y],2,length(t[y])-1);
              x:=x-1;
            end
                 else
            begin
              t[y]:=copy(t[y],1,x-2)+copy(t[y],x,length(t[y])-x+1);
              x:=x-1;
            end;
          coulFond(GrisClair);
          coulTexte(GrisClair);
          gotoxy(1,y-lh+2);
          write(graf,lignevide);
          coulTexte(Noir);
          gotoxy(1,y-lh+2);
          write(graf,t[y]);
        end
             else
        begin
          if y>1 then
            begin
              chaine:=t[y];
              for i:=y to (nfin-1) do t[i]:=t[i+1];
              t[nfin]:='';
              nfin:=nfin-1;
              y:=y-1;
              x:=length(t[y])+1;
              if x>80 then x:=80;
              chaine:=t[y]+chaine;
              Decale_Lignes(y,chaine);
              if y<lh then Calcul_Fenetre
                      else Affiche_Texte(2,nl+1,1,80);
            end
                 else
            Avertissement('Haut Document');
        end;
    end
              else
    begin
      if y>1 then
        begin
          for i:=y to (nfin-1) do t[i]:=t[i+1];
          nfin:=nfin-1;
          y:=y-1;
          x:=length(t[y])+1;
          if x>80 then x:=80;
          if y<lh then Calcul_Fenetre
                  else Affiche_Texte(2,nl+1,1,80);
        end
             else
        Avertissement('Haut Document');
    end;
end;



procedure Gestion_Retour_Chariot;
{ Gäre le comportement de la touche EntrÇe }

var i:integer;
    chaine:string;

begin
    if nfin<nmax then
        begin
            modif:=true;
            for i:=nfin downto y+1 do t[i+1]:=t[i];
            nfin:=nfin+1;
            if x=length(t[y])+1 then
                t[y+1]:=''
                                else
                begin
                    t[y+1]:=copy(t[y],x,length(t[y])-x+1);
                    t[y]:=copy(t[y],1,x-1);
                end;
            x:=1;
            y:=y+1;
            if y>lh+nl-1 then Calcul_Fenetre
                         else Affiche_Texte(2,nl+1,1,80);
        end
                 else
        Avertissement('Document plein: insertion impossible');
end;



procedure Gestion_Touche_Tab;
{ Gäre le comportement de la touche TABULATE }

var i:integer;

begin
    for i:=1 to 4 do Insere_Caractere(' ');
end;



procedure Gestion_Caractere(touche:char);
{ Gäre l'insertion d'un caractäre ainsi que la touche DEL }

begin
    if pos(touche,affichable)<>0 then
        Insere_Caractere(touche)
                                 else
        if touche=rc then
            Gestion_Retour_Chariot
                     else
            if touche=del then
                Gestion_Touche_Del
                          else
                if touche=tab then
                    Gestion_Touche_Tab;
end;



{ Programme principal }

begin

    { codes de commande divers }
    nul:=chr(0);    { Code ASCII du caractäre NULL }
    del:=chr(8);    { Code ASCII de la touche DEL }
    tab:=chr(9);    { Code ASCII de la touche TAB }
    rc:=chr(13);    { Code ASCII du retour chariot }


    { codes des touches de dÇplacement et de fonction }
    touchesdepl:=chr(75)+chr(77)+chr(72)+chr(80)+chr(73);
    touchesdepl:=touchesdepl+chr(81)+chr(71)+chr(79);
    touchesfonc:=chr(25)+chr(49)+chr(38)+chr(31)+chr(23)+chr(16);
    touchesfonc:=touchesfonc+chr(59)+chr(60)+chr(61);

    { liste de tous les caractäres affichables }
    affichable:=' !"#$%&'+chr(39)+'()*+,-./0123456789:;<=>?@ABCDEFGHIJ';
    affichable:=affichable+'KLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrst';
    affichable:=affichable+'uvwxyz{|}~';
    for i:=128 to 156 do affichable:=affichable+chr(i);
    affichable:=affichable+chr(160)+chr(161)+chr(162)+chr(163)+chr(225);
    affichable:=affichable+chr(230)+chr(248)+chr(21);

    nl:=20;
    lignevide:='';
    lignegrise:='';
    for i:=1 to 80 do
        begin
            lignevide:=lignevide+chr(219);
            lignegrise:=lignegrise+chr(176);
        end;
    fini:=false;
    input:=false;
    shift:=false;
    caps:=false;
    fonction:=false;
    modif:=false;
    textemem:=false;
    langage:=1;
    clrscr;
    modeGraphique;
    ChangeCurseur(ptrSablier);
    Affiche_Menu;
    Dessine_Clavier;
    Dessine_Touches;
    Efface_Texte;
    Affiche_Texte(2,nl+1,1,80);
    if paramCount=1 then Load(paramStr(1));
    ChangeCurseur(ptrFleche);

    { Boucle principale }
    repeat
        if textemem then Affiche_Curseur;
        Affiche_Ligne_Etat;
        Teste_touche(touche);
        if textemem then Eteind_Curseur;
        if fonction then
            begin
                if (pos(touche,touchesdepl)<>0) and textemem then
                        Deplacements(touche)
                                                             else
                        if pos(touche,touchesfonc)<>0 then Fonctions(touche);
            end
                    else
            if textemem then
                begin
                    Gestion_Caractere(touche);
                end;
    until fini;
    modeTexte;
    clrscr;
end.



{ Fin du programme }