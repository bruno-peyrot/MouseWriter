UNIT GraphLi2;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                                                                           }
{                                GraphLIB                                   }
{                                                                           }
{      - BibliothŠque de proc‚dures Turbo Pascal (mode graphique) -         }
{                                                                           }
{                par Jean-Edouard & Thomas LACHAND-ROBERT                   }
{                                                                           }
{        Modifi‚e par B. PEYROT pour le programme MouseWriter               }
{                                                                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

INTERFACE

{$L Graph}

USES
    Dos,
    Crt,
    Graph,
    TurboLib;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
CONST
     dessFond : Boolean = True;        { dessin du fond du caractŠre }
     demiCar  : Boolean = False;       { dessin d'un demi caractŠre }


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
TYPE
    typSauvGrf = RECORD                   { sauvegarde de paramŠtres ‚cran }
                    cTexte : Byte;     { couleur du texte }
                    cFond  : Byte;     { couleur du fond }
                    curX   : Byte;     { position horizontale du curseur }
                    curY   : Byte;     { position verticale du curseur }
              END;

    posTxt = RECORD         { un point d'affichage sur l'‚cran }
                   x, y : Byte;
             END;

    rectTxt = RECORD        { un rectangle d‚fini par deux points }
              CASE Byte OF
                   1 : (gh, db : posTxt);
                   2 : (x1, y1 ,x2, y2 : Byte);
              END;

    point = RECORD          { position d'un point en mode graphique }
                  x, y : Integer;
            END;

    rect = RECORD           { un rectangle graphique }
           CASE Byte OF
                1 : (gh, db : point);
                2 : (x1, y1, x2, y2 : Integer);
           END;

    fontCar = Array [0..13] OF Byte;         { 14 octets forment un caractŠre }
    typGrFont   = Array [0..255] OF fontCar; { police de caractŠres graphique }

    ptrCurseurSouris = ^curseurSouris;  { pointeur sur une forme souris }
    curseurSouris = RECORD
                          masqueEcran   : ARRAY [0..15] OF Word;
                          masqueCurseur : ARRAY [0..15] OF Word;
                          pointChaud    : point;
                    END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
VAR
   curMode : (texte, graphique);

   grDriver, grMode : Integer;   { carte et mode graphique courants }
   modeCouleur : Boolean;        { carte couleur ? }
   graf : Text;                  { fichier d'‚criture en mode graphique }
   grNbPlans,                    { nb de plans graphiques ds le mode courant }
   grActPage,                    { page graphique active }
   grVisPage,                    { page visible courante }
   grPosX, grPosY,               { position du curseur d'‚criture graphique }
   grHFont,                      { hauteur d'affichage du font graphique }
   grClTexte, grClFond : Byte;   { couleurs d'affichage courantes }
   grSeg0, grSeg1,               { Segments m‚moire des pages 1 et 2 }
   grHLigne : Word;              { hauteur d'un interligne graphique }
   grFont : typGrFont;           { font graphique courant }
   grOfsY : Array [0..479] OF Word; { Offsets verticaux en m‚moire graphique }

{ÄÄVariables du gestionnaire sourisÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

   sourisOk : Boolean;           { pr‚sence de la souris }
   curseurVis : Integer;         { visibilit‚ du curseur souris }
   cmdSouris,                    { commande en cours d'ex‚cution }
   boutSouris : Integer;         { dernier bouton souris press‚ (0-3) }
   posSouris  : point;           { position du pointeur de la souris }
   ptrFleche,                    { pointeur souris en forme de flŠche }
   ptrMain,                      { pointeur souris en forme de main }
   ptrCroix,                     { pointeur souris en forme de croix }
   ptrSablier,                   { pointeur souris en forme de sablier }
   ptrTexte : ptrCurseurSouris;  { pointeur souris en forme de double-flŠche }
   reg : Registers;


{ outils d'usage g‚n‚ral }
PROCEDURE modeGraphique;
PROCEDURE modeTexte;
PROCEDURE attendAction;

{ outils de gestion souris }
PROCEDURE cacheSouris;
PROCEDURE montreSouris;
PROCEDURE execSouris;
PROCEDURE changeCurseur (nouvForme : ptrCurseurSouris);
PROCEDURE positionSouris (x, y : Integer);

{ outils de gestion d'‚cran }
PROCEDURE centreTexte (posY : Byte;   phrase : str80);
FUNCTION  litDonnee (posX,posY,longMax,typ : Byte; parDefaut : str80) : str80;
PROCEDURE sauvegarde (VAR s : typSauvGrf);
PROCEDURE restaure (s : typSauvGrf);
PROCEDURE coulTexte (coul : couleur);
PROCEDURE coulFond (coul : couleur);
PROCEDURE inverseTexte (col, ligne, long : Byte);
PROCEDURE sauveRectTexte (x1, y1, x2, y2 : Byte;   donPtr : Pointer);
PROCEDURE litRectTexte (x1, y1, x2, y2 : Byte;   donPtr : Pointer);
PROCEDURE initRect (VAR r : rectTxt;  x1, y1, x2, y2 : Byte);
FUNCTION  ptDsRect (pt : point;  r : rect) : Boolean;
PROCEDURE rTxtToRect (rTxt : rectTxt;  VAR r : Rect);
PROCEDURE ptToPTxt (pt : point;  VAR pTxt : posTxt);
FUNCTION  tailleRTxt (rT : rectTxt) : Word;
PROCEDURE EffaceRect (r : rect);
PROCEDURE rectTexte(x1, y1, x2, y2, quel : Byte;   plein : Boolean);

{ indirections Turbo Pascal }
PROCEDURE setActivePage (actPage : Byte);
PROCEDURE setVisualPage (vPage : Byte);
PROCEDURE GotoXY (x, y : Byte);
FUNCTION  WhereX : Byte;
FUNCTION  WhereY : Byte;
PROCEDURE ClrScr;


IMPLEMENTATION

{ Routines assembl‚es dans GRAPH.OBJ }
{$F+}
PROCEDURE dessCar (xPos, yPos, car : Byte); External;
PROCEDURE inverseXY (xPos, yPos : Byte); External;
PROCEDURE readPlan (plan: Byte); External;
PROCEDURE writePlan (plan: Byte); External;
{$F-}


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{       Comme TurboLib, avec modifications pour le mode graphique.          }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE attendAction;
VAR
   car : Char;

BEGIN
     REPEAT
           appelTache;
           execSouris;
     UNTIL KeyPressed OR (boutSouris <> 0);
     WHILE KeyPressed DO
           car := ReadKey;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{       Comme TurboLib, avec modifications pour le mode graphique.          }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE centreTexte (posY : Byte;   phrase : str80);
VAR
   long : Byte;

BEGIN
     long := Length(phrase) DIV 2;
     GotoXY(xMil-long,posY);
     Write(graf,phrase);
END;



{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{       Comme TurboLib, avec modifications pour le mode graphique.          }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION litDonnee (posX,posY,longMax,typ : Byte; parDefaut : str80) : str80;
CONST
     carCurseur = #254; { caractŠre ş }

VAR
   phrase : String;
   ligne : str80;
   car : Char;
   compte, posCurseur : Byte;
   il, posExposant : Integer;
   carPoint, valable : Boolean;

   PROCEDURE entreUnCar;
   BEGIN
      IF (posCurseur <= compte) OR
         ((posCurseur = compte+1) AND (compte < longMax)) THEN
      BEGIN
          IF (typ = typeReel) AND (phrase[posCurseur] = '.') THEN
             carPoint := FALSE;
          phrase[posCurseur]:=car;
          IF posCurseur > compte THEN compte:= posCurseur;
          GotoXY(posX+posCurseur-1,posY);
          Write(graf,car);
          posCurseur := posCurseur+1;
      END;
   END;

   PROCEDURE detruitCar;
   VAR
      il : Byte;

   BEGIN
        IF (typ = typeReel) AND (phrase[posCurseur] = '.') THEN
           carPoint := FALSE;
        IF (typ = typeReel) AND (phrase[posCurseur] = 'E') THEN
           BEGIN
                posExposant := 0;
                IF phrase[posCurseur+1] = '-' THEN
                   BEGIN
                        FOR il := posCurseur+1 TO compte DO
                            phrase[il] := phrase[il+1];
                        compte := compte-1;
                   END;
           END;
        FOR il := posCurseur TO compte DO
            phrase[il] := phrase[il+1];
        GotoXY(posX,posY);
        Write(graf,Copy(phrase,1,longMax));
        compte := compte-1;
   END;

BEGIN
     IF typ > typeAlpha THEN                { suppression des espaces de tˆte }
        WHILE parDefaut[1] = ' ' DO
              parDefaut := Copy(parDefaut,2,Length(parDefaut)-1);
     compte := 0;
     FillChar(ligne,80,carCurseur);
     ligne[0]:=#80;
     IF typ = typeReel THEN
     BEGIN
          carPoint := (Pos('.',parDefaut) <> 0);
          posExposant := Pos('E',parDefaut);
     END;
     posCurseur := Length(parDefaut)+1;
     IF posCurseur > 1 THEN
     BEGIN
          compte := posCurseur-1;
          Delete(ligne,1,compte);
          phrase := Concat(parDefaut,ligne);
     END
     ELSE
     BEGIN
         compte := 0;
         phrase := ligne;
     END;
     GotoXY(posX,posY);
     Write(graf,Copy(phrase,1,longMax));
     valable := FALSE;
     REPEAT
           il := 0;
           car := carNul;
           REPEAT
                 GotoXY(posX+posCurseur-1,posY);
                 il := Succ(il);
                 IF il > 32000 THEN
                    il := 0;
                 IF Odd(il DIV 100) THEN
                    IF phrase[posCurseur] = carCurseur THEN
                       Write(graf,' ')
                    ELSE
                       Write(graf,phrase[posCurseur])
                 ELSE
                    Write(graf,carCurseur);
                 IF KeyPressed THEN
                 BEGIN
                      car := ReadKey;
                      IF (car = toucheCorr) AND (posCurseur > 1) THEN
                      BEGIN
                           posCurseur := posCurseur-1;
                           IF posCurseur <= compte THEN
                              detruitCar;
                      END;
                      IF (car = carNul) AND KeyPressed THEN
                      BEGIN
                           car := ReadKey;
                           GotoXY(posX+posCurseur-1,posY);
                           IF posCurseur <= longMax THEN
                              Write(graf,phrase[posCurseur])
                           ELSE
                              Write(graf,' ');

                           CASE car OF
                                flchDebut  : posCurseur := 1;

                                flchFin    : posCurseur := compte+1;

                                flchDroite : IF posCurseur <= longMax THEN
                                                posCurseur := posCurseur + 1;

                                flchGauche : IF posCurseur > 1 THEN
                                                posCurseur := posCurseur - 1;

                                toucheIns  :
                                IF (compte<longMax) AND (posCurseur<=compte)
                                THEN
                                BEGIN   {Insertion}
                                     compte := compte+1;
                                     FOR il := compte DOWNTO posCurseur+1 DO
                                         phrase[il] := phrase[il-1];
                                     phrase[posCurseur] := ' ';
                                     GotoXY(posX,posY);
                                     Write(graf,Copy(phrase,1,longMax));
                                END;

                                touchAnnl :
                                IF posCurseur <= compte THEN
                                   detruitCar;
                           END;
                           car := carNul;
                      END;

                      IF car = carEsc THEN
                      BEGIN
                           phrase[1] := carEsc;
                           valable:= TRUE;
                           compte := 1;
                      END;
                 END;
           UNTIL car <> carNul;

           IF phrase[1] <> carEsc THEN
              CASE typ OF

                typeAlpha  : IF car IN [' '..'Š'] THEN
                                entreUnCar;

                typeEntier : IF (car IN ['0'..'9']) OR ((car = '-')
                                AND (posCurseur = 1)) THEN
                                entreUnCar;

                typeReel   : IF (car IN ['0'..'9']) OR (car = '.') OR
                                ((car = '-') AND ((posCurseur = 1) OR
                                (posCurseur = posExposant+1))) OR
                                ((car = 'E') AND (posExposant = 0) AND
                                (phrase[posCurseur-1] IN ['0'..'9'])) THEN
                             BEGIN
                                  IF car = 'E' THEN
                                     posExposant := posCurseur;
                                  IF (NOT carPoint) OR (car <> '.') THEN
                                     entreUnCar;
                                  IF car = '.' THEN
                                     carPoint := TRUE;
                             END;
              END;

              IF car = carRet THEN
              BEGIN
                   valable := TRUE;
                   IF typ > typeAlpha THEN
                      IF (compte = 0) OR ((phrase[1] = '-')
                         AND NOT (phrase[2] IN ['0'..'9']))
                         OR (Pos(' ',phrase) IN [1..compte]) THEN
                            valable := FALSE;
                   IF (typ = typeReel) AND (posExposant <> 0) THEN
                      IF NOT (phrase[posExposant+1] IN ['0'..'9']) THEN
                         IF NOT (phrase[posExposant+2] IN ['0'..'9']) THEN
                            valable := FALSE;
                   IF NOT valable THEN
                   BEGIN
                        Sound(200);
                        Delay(200);
                        NoSound;
                   END;
              END;

     UNTIL valable;
     phrase := Copy(phrase,1,compte);
     litDonnee := phrase;
     GotoXY(posX,posY);
     FillChar(ligne,80,' ');
     ligne[0]:=#80;
     IF phrase[1] <> carEsc THEN
          Write(graf,phrase,Copy(ligne,1,longMax-compte+1))
     ELSE
          Write(graf,parDefaut,Copy(ligne,1,longMax-Length(parDefaut)+1));
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Sauvegarde certaines valeurs en cours (couleurs, position curseur).    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE sauvegarde (VAR s : typSauvGrf);
BEGIN
     WITH s DO
     BEGIN
          cTexte := grClTexte;
          cFond := grClFond;
          curX := whereX;
          curY := whereY;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{               Restaure les valeurs se trouvant dans 's'.                  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE restaure (s : typSauvGrf);
BEGIN
     WITH s DO
     BEGIN
          grClTexte := cTexte;
          grClFond := cFond;
          Gotoxy(curX,curY);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{         Change la couleur du texte … 'coul' (noir … blanc).               }
{ (Si l'adaptateur est monochrome, la couleur est obligatoirement le blanc) }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE coulTexte (coul : couleur);
BEGIN
     IF modeCouleur THEN
        grClTexte := coul;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{          Change la couleur du fond … 'coul' (noir … grisClair).           }
{ (Si l'adaptateur est monochrome, la couleur est obligatoirement le noir)  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE coulFond (coul : couleur);
BEGIN
     IF modeCouleur THEN
        grClFond := coul;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Inversion du texte commencant position 'posX','posY' et de longueur 'long'}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE inverseTexte (col, ligne, long : Byte);
VAR
   il : Integer;

BEGIN
     cacheSouris;
     FOR il := 0 TO long-1 DO
         inverseXY(col+il,ligne);
     montreSouris;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Copie la zone rectangulaire d‚finie par les deux points textes       }
{          'x1,y1' et 'x2,y2' de l'‚cran courant dans donPtr^.              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE sauveRectTexte (x1, y1, x2, y2 : Byte;   donPtr : Pointer);
VAR
   offset2, offset, row, il, deb, fin, i : Word;

BEGIN
     IF donPtr <> NIL THEN
     BEGIN
          cacheSouris;
          offset2 := 0;
          row := x2-x1+1;
          offset := x1-1;
          deb := (y1-1)*grHligne;
          fin := (y2*grHligne)-1;
          FOR i := 0 TO grNbPlans DO
          BEGIN
               IF grDriver <> HercMono THEN
                  readPlan(i);
               FOR il := deb TO fin DO
               BEGIN
                    System.Move(Mem[baseEcran:grOfsY[il]+offset],
                                Mem[Seg(donPtr^):Ofs(donPtr^)+offset2],row);
                    offset2 := offset2 + row;
               END;
          END;
          montreSouris;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Copie la zone rectangulaire d‚finie par les deux points textes       }
{           'x1,y1' et 'x2,y2' de donPtr^ dans l'‚cran courant.             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE litRectTexte (x1, y1, x2, y2 : Byte;   donPtr : Pointer);
VAR
   offset2, offset, row, il, deb, fin, i : Word;

BEGIN
     IF donPtr <> NIL THEN
     BEGIN
          cacheSouris;
          offset2 := 0;
          row := x2-x1+1;
          offset := x1-1;
          deb := (y1-1)*grHligne;
          fin := (y2*grHligne)-1;
          FOR i := 0 TO grNbPlans DO
          BEGIN
               IF grDriver <> HercMono THEN
                  writePlan(i);
               FOR il := deb TO fin DO
               BEGIN
                    System.Move(Mem[Seg(donPtr^):Ofs(donPtr^)+offset2],
                                Mem[baseEcran:grOfsY[il]+offset],row);
                    offset2 := offset2 + row;
               END;
          END;
          IF grDriver <> HercMono THEN
             writePlan(15);
          montreSouris;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{            Initialise le rectangle 'r' aux valeurs donn‚es.               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE initRect (VAR r : rectTxt;  x1, y1, x2, y2 : Byte);
BEGIN
     r.x1 := x1;
     r.y1 := y1;
     r.x2 := x2;
     r.y2 := y2;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{         Teste si le point 'pt' se trouve dans le rectangle 'r'.           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION ptDsRect (pt : point;  r : rect) : Boolean;
BEGIN
     WITH r, pt DO
          ptDsRect := ((x >= x1) AND (x <= x2) OR (x >= x2) AND (x <= x1))
                      AND
                      ((y >= y1) AND (y <= y2) OR (y >= y2) AND (y <= y1));
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Transforme le rectangle texte 'rTxt' en un rectangle graphique.      }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE rTxtToRect (rTxt : rectTxt;  VAR r : Rect);
BEGIN
     WITH r DO
     BEGIN
          y1 := (rTxt.y1-1)*grHLigne;
          x1 := (rTxt.x1-1)*8;
          y2 := (rTxt.y2*grHligne)-1;
          x2 := (rTxt.x2*8)-1;
     END;
     IF r.y2 > GetMaxY THEN
        r.y2 := GetMaxY;
     IF r.x2 > GetMaxX THEN
        r.x2 := GetMaxX;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{          Transforme le point 'pt' en un point texte ds 'pTxt'.            }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ptToPTxt (pt : point;  VAR pTxt : posTxt);
BEGIN
     pTxt.x := (pt.x DIV 8) + 1;
     pTxt.y := (pt.y DIV grHLigne) + 1;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Calcule la taille m‚moire occup‚e par le rectangle texte 'rT'.       }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION tailleRTxt (rT : rectTxt) : Word;
VAR
   mul : Word;

BEGIN
     mul := grNbPlans + 1;
     WITH rT DO
          tailleRTxt := mul * (x2-x1+1) * (y2-y1+1) * grHligne;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{               Efface le rectangle 'r' (le dessine en noir).               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE EffaceRect(r : rect);
BEGIN
     cacheSouris;
     SetFillStyle(solidFill,noir);
     WITH r DO
          Bar(x1,y1,x2,y2);
     montreSouris;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Dessine le rectangle d‚fini par les deux points textes 'x1,y1' et 'x2,y2'.}
{  'quel' indique la largeur de la bordure du rectangle (0,1 ou 2 lignes).  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE rectTexte (x1, y1, x2, y2, quel : Byte;  plein : Boolean);
VAR
   largeur, hauteur, il, curX, curY : Byte;
   haut, bas, milieu : String;
   topLeft, botRight : Word;
   rt : rectTxt;
   r : Rect;

BEGIN
     IF quel IN [0..2] THEN
     BEGIN
       IF x2 > absX THEN
          x2 := absX;
       IF y2 > absY THEN
          y2 := absY;
       curX := whereX;
       curY := whereY;
       IF x2 < x1 THEN
       BEGIN
            il := x2;
            x2 := x1;
            x1 := il;
       END;
       IF y2 < y1 THEN
       BEGIN
            il := y2;
            y2 := y1;
            y1 := il;
       END;
       IF plein THEN
       BEGIN
          initRect(rt,x1,y1,x2,y2);
          rTxtToRect(rt,r);
          IF quel = 0 THEN
             EffaceRect(r)
          ELSE
          BEGIN
               cacheSouris;
               SetFillStyle(solidFill,grClFond);
               WITH r DO
                    Bar(x1,y1,x2,y2);
               montreSouris;
               dessFond := False;
               IF (x1 <> x2) AND (y1 <> y2) THEN
               BEGIN
                    largeur := x2 - x1 - 1;
                    hauteur := y2 - y1 - 1;
                    CASE quel OF
                         1 :
                         BEGIN
                              haut := Concat('Ú',Copy(ligne1,1,largeur),'¿');
                              milieu := '³';
                              bas := Concat('À',Copy(ligne1,1,largeur),'Ù');
                         END;

                         2 :
                         BEGIN
                              haut := Concat('É',Copy(ligne2,1,largeur),'»');
                              milieu := 'º';
                              bas := Concat('È',Copy(ligne2,1,largeur),'¼');
                         END;
                    END;
                    GotoXY(x1,y1);
                    Write(graf,haut);
                    FOR il := 1 TO hauteur DO
                    BEGIN
                         GotoXY(x1,y1+il);
                         Write(graf,milieu);
                         GotoXy(x1+largeur+1,y1+il);
                         Write(graf,milieu);
                    END;
                    GotoXY(x1,y2);
                    Write(graf,bas);
                    Gotoxy(curX,curY);
              END;
              dessFond := True;
          END;
       END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{             Force la position du curseur souris … 'x', 'y'.               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE positionSouris (x, y : Integer);
BEGIN
     IF sourisOk THEN
     BEGIN
          WITH reg DO
          BEGIN
               AX := 4;
               CX := x;
               DX := y;
          END;
          Intr($33,reg);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                 Cr‚e un curseur souris en forme de flŠche.                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE cFleche;
BEGIN
     WITH ptrFleche^ DO
     BEGIN
          masqueEcran[0]  := $3FFF; { 0011111111111111 }
          masqueEcran[1]  := $1FFF; { 0001111111111111 }
          masqueEcran[2]  := $0FFF; { 0000111111111111 }
          masqueEcran[3]  := $07FF; { 0000011111111111 }
          masqueEcran[4]  := $03FF; { 0000001111111111 }
          masqueEcran[5]  := $01FF; { 0000000111111111 }
          masqueEcran[6]  := $00FF; { 0000000011111111 }
          masqueEcran[7]  := $007F; { 0000000001111111 }
          masqueEcran[8]  := $003F; { 0000000000111111 }
          masqueEcran[9]  := $001F; { 0000000000011111 }
          masqueEcran[10] := $01FF; { 0000000111111111 }
          masqueEcran[11] := $10FF; { 0001000011111111 }
          masqueEcran[12] := $30FF; { 0011000011111111 }
          masqueEcran[13] := $F87F; { 1111100001111111 }
          masqueEcran[14] := $F87F; { 1111100001111111 }
          masqueEcran[15] := $FC3F; { 1111110000111111 }

          masqueCurseur[0]  := $0000; { 0000000000000000 }
          masqueCurseur[1]  := $4000; { 0100000000000000 }
          masqueCurseur[2]  := $6000; { 0110000000000000 }
          masqueCurseur[3]  := $7000; { 0111000000000000 }
          masqueCurseur[4]  := $7800; { 0111100000000000 }
          masqueCurseur[5]  := $7C00; { 0111110000000000 }
          masqueCurseur[6]  := $7E00; { 0111111000000000 }
          masqueCurseur[7]  := $7F00; { 0111111100000000 }
          masqueCurseur[8]  := $7F80; { 0111111110000000 }
          masqueCurseur[9]  := $7FC0; { 0111111111000000 }
          masqueCurseur[10] := $7C00; { 0111110000000000 }
          masqueCurseur[11] := $4600; { 0100011000000000 }
          masqueCurseur[12] := $0600; { 0000011000000000 }
          masqueCurseur[13] := $0300; { 0000001100000000 }
          masqueCurseur[14] := $0300; { 0000001100000000 }
          masqueCurseur[15] := $0000; { 0000000000000000 }
          pointChaud.x := 0;
          pointChaud.y := 0;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                  Cr‚e un curseur souris en forme de croix.                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE cCroix;
BEGIN
     WITH ptrCroix^ DO
     BEGIN
          masqueEcran[0]  := $FFFF; { 1111111111111111 }
          masqueEcran[1]  := $FFFF; { 1111111111111111 }
          masqueEcran[2]  := $FFFF; { 1111111111111111 }
          masqueEcran[3]  := $FFFF; { 1111111111111111 }
          masqueEcran[4]  := $FFFF; { 1111111111111111 }
          masqueEcran[5]  := $FFFF; { 1111111111111111 }
          masqueEcran[6]  := $FFFF; { 1111111111111111 }
          masqueEcran[7]  := $FFFF; { 1111111111111111 }
          masqueEcran[8]  := $FFFF; { 1111111111111111 }
          masqueEcran[9]  := $FFFF; { 1111111111111111 }
          masqueEcran[10] := $FFFF; { 1111111111111111 }
          masqueEcran[11] := $FFFF; { 1111111111111111 }
          masqueEcran[12] := $FFFF; { 1111111111111111 }
          masqueEcran[13] := $FFFF; { 1111111111111111 }
          masqueEcran[14] := $FFFF; { 1111111111111111 }
          masqueEcran[15] := $FFFF; { 1111111111111111 }

          masqueCurseur[0]  := $0100; { 0000000100000000 }
          masqueCurseur[1]  := $0100; { 0000000100000000 }
          masqueCurseur[2]  := $0100; { 0000000100000000 }
          masqueCurseur[3]  := $0100; { 0000000100000000 }
          masqueCurseur[4]  := $0100; { 0000000100000000 }
          masqueCurseur[5]  := $0100; { 0000000100000000 }
          masqueCurseur[6]  := $0100; { 0000000100000000 }
          masqueCurseur[7]  := $FFFE; { 1111111111111110 }
          masqueCurseur[8]  := $0100; { 0000000100000000 }
          masqueCurseur[9]  := $0100; { 0000000100000000 }
          masqueCurseur[10] := $0100; { 0000000100000000 }
          masqueCurseur[11] := $0100; { 0000000100000000 }
          masqueCurseur[12] := $0100; { 0000000100000000 }
          masqueCurseur[13] := $0100; { 0000000100000000 }
          masqueCurseur[14] := $0100; { 0000000100000000 }
          masqueCurseur[15] := $0000; { 0000000000000000 }
          pointChaud.x := 7;
          pointChaud.y := 7;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                   Cr‚e un curseur souris en forme de main.                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE cMain;
BEGIN
     WITH ptrMain^ DO
     BEGIN
          masqueEcran[0]  := $F3FF; { 1111001111111111 }
          masqueEcran[1]  := $E1FF; { 1110000111111111 }
          masqueEcran[2]  := $E1FF; { 1110000111111111 }
          masqueEcran[3]  := $E1FF; { 1110000111111111 }
          masqueEcran[4]  := $E1FF; { 1110000111111111 }
          masqueEcran[5]  := $E049; { 1110000001001001 }
          masqueEcran[6]  := $E000; { 1110000000000000 }
          masqueEcran[7]  := $E000; { 1110000000000000 }
          masqueEcran[8]  := $8000; { 1000000000000000 }
          masqueEcran[9]  := $0000; { 0000000000000000 }
          masqueEcran[10] := $0000; { 0000000000000000 }
          masqueEcran[11] := $0000; { 0000000000000000 }
          masqueEcran[12] := $0000; { 0000000000000000 }
          masqueEcran[13] := $0000; { 0000000000000000 }
          masqueEcran[14] := $0000; { 0000000000000000 }
          masqueEcran[15] := $8001; { 1000000000000001 }

          masqueCurseur[0]  := $0C00; { 0000110000000000 }
          masqueCurseur[1]  := $1200; { 0001001000000000 }
          masqueCurseur[2]  := $1200; { 0001001000000000 }
          masqueCurseur[3]  := $1200; { 0001001000000000 }
          masqueCurseur[4]  := $1200; { 0001001000000000 }
          masqueCurseur[5]  := $13B6; { 0001001110110110 }
          masqueCurseur[6]  := $1249; { 0001001101001001 }
          masqueCurseur[7]  := $1249; { 0001001101001001 }
          masqueCurseur[8]  := $7249; { 0111001101001001 }
          masqueCurseur[9]  := $9001; { 1001000000000001 }
          masqueCurseur[10] := $9001; { 1001000000000001 }
          masqueCurseur[11] := $9001; { 1001000000000001 }
          masqueCurseur[12] := $8001; { 1000000000000001 }
          masqueCurseur[13] := $8001; { 1000000000000001 }
          masqueCurseur[14] := $8001; { 1000000000000001 }
          masqueCurseur[15] := $7FFE; { 0111111111111110 }
          pointChaud.x := 5;
          pointChaud.y := 0;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                 Cr‚e un curseur souris en forme de sablier.               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE cSablier;
BEGIN
     WITH ptrSablier^ DO
     BEGIN
          masqueEcran[0]  := $0000; { 0000000000000000 }
          masqueEcran[1]  := $0000; { 0000000000000000 }
          masqueEcran[2]  := $0000; { 0000000000000000 }
          masqueEcran[3]  := $8001; { 1000000000000001 }
          masqueEcran[4]  := $C003; { 1100000000000011 }
          masqueEcran[5]  := $E007; { 1110000000000111 }
          masqueEcran[6]  := $F00F; { 1111000000001111 }
          masqueEcran[7]  := $F81F; { 1111100000011111 }
          masqueEcran[8]  := $F81F; { 1111100000011111 }
          masqueEcran[9]  := $F00F; { 1111000000001111 }
          masqueEcran[10] := $E007; { 1110000000000111 }
          masqueEcran[11] := $C003; { 1100000000000011 }
          masqueEcran[12] := $8001; { 1000000000000001 }
          masqueEcran[13] := $0000; { 0000000000000000 }
          masqueEcran[14] := $0000; { 0000000000000000 }
          masqueEcran[15] := $0000; { 0000000000000000 }

          masqueCurseur[0]  := $0000; { 0000000000000000 }
          masqueCurseur[1]  := $7FFE; { 0111111111111110 }
          masqueCurseur[2]  := $6006; { 0110000000000110 }
          masqueCurseur[3]  := $300C; { 0011000000001100 }
          masqueCurseur[4]  := $1818; { 0001100000011000 }
          masqueCurseur[5]  := $0C30; { 0000110000110000 }
          masqueCurseur[6]  := $0660; { 0000011001100000 }
          masqueCurseur[7]  := $0240; { 0000001001000000 }
          masqueCurseur[8]  := $0240; { 0000001001000000 }
          masqueCurseur[9]  := $0660; { 0000011001100000 }
          masqueCurseur[10] := $0DB0; { 0000110110110000 }
          masqueCurseur[11] := $1BD8; { 0001101111011000 }
          masqueCurseur[12] := $37EC; { 0011011111101100 }
          masqueCurseur[13] := $67E6; { 0110011111100110 }
          masqueCurseur[14] := $7FFE; { 0111111111111110 }
          masqueCurseur[15] := $0000; { 0000000000000000 }
          pointChaud.x := 0;
          pointChaud.y := 0;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{           Cr‚e un curseur souris en forme de flŠche d'insertion.          }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE cTexte;
BEGIN
     WITH ptrTexte^ DO
     BEGIN
          masqueEcran[0]  := $FFFF; { 1111111111111111 }
          masqueEcran[1]  := $FDBF; { 1111110110111111 }
          masqueEcran[2]  := $F99F; { 1111100110011111 }
          masqueEcran[3]  := $F18F; { 1111000110001111 }
          masqueEcran[4]  := $E187; { 1110000110000111 }
          masqueEcran[5]  := $C003; { 1100000000000011 }
          masqueEcran[6]  := $8001; { 1000000000000001 }
          masqueEcran[7]  := $0000; { 0000000000000000 }
          masqueEcran[8]  := $0000; { 0000000000000000 }
          masqueEcran[9]  := $8001; { 1000000000000001 }
          masqueEcran[10] := $C003; { 1100000000000011 }
          masqueEcran[11] := $E187; { 1110000110000111 }
          masqueEcran[12] := $F18F; { 1111000110001111 }
          masqueEcran[13] := $F99F; { 1111100110011111 }
          masqueEcran[14] := $FDBF; { 1111110110111111 }
          masqueEcran[15] := $FFFF; { 1111111111111111 }

          masqueCurseur[0]  := $0000; { 0000000000000000 }
          masqueCurseur[1]  := $0000; { 0000000000000000 }
          masqueCurseur[2]  := $0000; { 0000000000000000 }
          masqueCurseur[3]  := $0420; { 0000010000100000 }
          masqueCurseur[4]  := $0C30; { 0000110000110000 }
          masqueCurseur[5]  := $1C38; { 0001110000111000 }
          masqueCurseur[6]  := $3FFC; { 0011111111111100 }
          masqueCurseur[7]  := $7FFE; { 0111111111111110 }
          masqueCurseur[8]  := $7FFE; { 0111111111111110 }
          masqueCurseur[9]  := $3FFC; { 0011111111111100 }
          masqueCurseur[10] := $1C38; { 0001110000111000 }
          masqueCurseur[11] := $0C30; { 0000110000110000 }
          masqueCurseur[12] := $0420; { 0000010000100000 }
          masqueCurseur[13] := $0000; { 0000000000000000 }
          masqueCurseur[14] := $0000; { 0000000000000000 }
          masqueCurseur[15] := $0000; { 0000000000000000 }
          pointChaud.x := 7;
          pointChaud.y := 7;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                        Cache le curseur souris.                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE cacheSouris;
BEGIN
     IF sourisOk THEN
     BEGIN
          IF curseurVis = 0 THEN
          BEGIN
               reg.AX := 2;
               Intr($33,reg);
          END;
          curseurVis := curseurVis - 1;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                       Montre le curseur souris.                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE montreSouris;
BEGIN
     IF sourisOk THEN
     BEGIN
          IF curseurVis = -1 THEN
          BEGIN
               reg.AX := 1;
               Intr($33,reg);
          END;
          curseurVis := curseurVis + 1;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{           Execute la commande souris d‚finie dans 'cmdSouris'.            }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE execSouris;
BEGIN
     IF sourisOk THEN
     BEGIN
          reg.AX := cmdSouris;
          Intr($33,reg);
          WITH reg DO
          BEGIN
               cmdSouris := AX;
               boutSouris := BX;
               posSouris.x := CX;
               posSouris.y := DX
          END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{            Initialise la commande souris … la gestion normale.            }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE debSouris;
BEGIN
     cmdSouris := 3;
     execSouris;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                           Initialise la souris.                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION initSouris : BOOLEAN;
VAR
   presente : Boolean;

BEGIN
     IF grDriver = HercMono THEN   { magouille de Microsoft }
        Mem[$40:$49] := 6;
     reg.AX := 0;
     Intr($33,reg);
     presente := (reg.AX = $FFFF);
     curseurVis := -1;
     IF presente THEN
     BEGIN
          NEW(ptrFleche);
          cFleche;
          NEW(ptrMain);
          cMain;
          NEW(ptrCroix);
          cCroix;
          NEW(ptrSablier);
          cSablier;
          NEW(ptrTexte);
          cTexte;
          debSouris;
     END
     ELSE
         boutSouris := 0;
     initSouris := presente;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{   Change la forme du curseur souris … celle point‚e dans 'nouvForme'.     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE changeCurseur (nouvForme : ptrCurseurSouris);
BEGIN
     IF sourisOk THEN
     BEGIN
          WITH reg, nouvForme^ DO
          BEGIN
               AX := 9;
               BX := pointChaud.x;
               CX := pointChaud.y;
               DX := Ofs(masqueEcran[0]);
               ES := Seg(masqueEcran[0]);
          END;
          Intr($33,reg);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{             Change le curseur souris de page graphique.                   }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE pageSouris (page : Byte);
BEGIN
     IF sourisOk THEN
     BEGIN
          cacheSouris;
          reg.AX := 29;
          reg.BX := page;
          Intr($33,reg);
          montreSouris;
          debSouris;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                        Passe en mode graphique.                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE modeGraphique;
VAR
   il : Integer;
   ficFont : File of typGrFont;

BEGIN
     IF curMode <> graphique THEN
     BEGIN
          grDriver := Detect;
          InitGraph(grDriver,grMode,repPrg);
          IF grDriver = VGA THEN
             grDriver := EGA;
          IF graphResult = 0 THEN
          BEGIN
               curMode := graphique;
               CASE grDriver OF
                    HercMono :
                    BEGIN
                         grNbPlans := 0;
                         grSeg0  := $B000;
                         grSeg1  := $B800;
                         FOR il := 0 TO GetMaxY DO
                           grOfsY[il] := (il AND 3) SHL 13 + (90 * (il SHR 2));
                    END;

                    EGA64 :
                    BEGIN
                         grNbPlans := 3;
                         grSeg0  := $B000;
                         grSeg1  := $B800;
                         FOR il := 0 TO GetMaxY DO
                             grOfsY[il] := il * 80;
                    END;

                    EGA,
                    EGAMono :
                    BEGIN
                         grNbPlans := 3;
                         grSeg0  := $A000;
                         grSeg1  := $A800;
                         FOR il := 0 TO GetMaxY DO
                             grOfsY[il] := il * 80;
                    END;

               END;
               modeCouleur := grDriver IN [EGA,EGA64];
               sourisOk := initSouris;
               montreSouris;
               SetActivePage(0);
               SetVisualPage(0);
                Assign(ficFont, repPrg+'MOUSEWRI.FON');
               {$I-}
               Reset(ficFont);
               {$I+}
               IF IOResult = 0 THEN
               BEGIN
                    Read(FicFont, grFont);
                    Close(FicFont);
                    grHLigne := 14;
                    grHFont := 14;
               END
               ELSE
                   FillChar(grFont, SizeOf(grFont), 0);
               absX := (GetMaxX+1) DIV 8;
               xMil := absX DIV 2;
               absY := (GetMaxY+1) DIV grHLigne;
               grPosX := 1;
               grPosY := 1;
          END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                          Passe en mode texte.                             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE modeTexte;
BEGIN
     IF curMode <> texte THEN
     BEGIN
          WHILE curseurVis >= 0 DO
                cacheSouris;
          CloseGraph;
          curMode := texte;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{               Dessine le caractŠre 'car' en mode graphique.               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE outGrCar (car : Char);
BEGIN
     CASE car OF
          #7 : unBip;
          toucheCorr : IF grPosX > 1 THEN
               BEGIN
                    grPosX := grPosX - 1;
                    dessCar(grPosX, grPosY, 32);
               END;
         #10 : IF grPosY < 25 THEN
                  grPosY := grPosY + 1;
         carRet : grPosX := 1;

         ELSE
             BEGIN
                  dessCar(grPosX, grPosY, Ord(car));
                  IF grPosX = absX THEN
                  BEGIN
                       grPosX := 1;
                       IF grPosY < 25 THEN
                          grPosY := grPosY + 1;
                  END
                  ELSE
                      grPosX := grPosX + 1;
             END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                 gestion du fichier texte d'affichage 'graf'.              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{$F+}
FUNCTION OpenGraph (VAR f:TextRec) : Integer;
BEGIN
     OpenGraph := 0;
END;

FUNCTION InOutGraph (VAR f:TextRec) : Integer;
VAR
   pos : Word;

BEGIN
     cacheSouris;
     WITH f DO
          IF mode = fmOutput THEN
          BEGIN
               pos := 0;
               While pos < BufPos DO
               BEGIN
                    outGrCar(BufPtr^[pos]);
                    pos := pos + 1;
               END;
               BufPos := 0;
          END;
     InOutGraph := 0;
     montreSouris;
END;

FUNCTION CloseGraph (VAR f:TextRec) : Integer;
BEGIN
     CloseGraph := 0;
END;
{$F-}


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{              assignation du fichier texte d'affichage 'graf'.             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE AssignGraph (VAR graf:Text);
BEGIN
     WITH TextRec(graf) DO
     BEGIN
          Handle := $FFFF;
          Mode := fmClosed;
          BufSize := SizeOf(Buffer);
          BufPtr := @Buffer;
          OpenFunc := @OpenGraph;
          InOutFunc := @InOutGraph;
          FlushFunc := @InOutGraph;
          CloseFunc := @CloseGraph;
          Name[0] := #0;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ cf proc‚dure Turbo Pascal.                                                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE setActivePage (actPage : Byte);
BEGIN
     grActPage := actPage;
     graph.setActivePage(actPage);
     IF grActPage = 0 THEN
        baseEcran := grSeg0
     ELSE
        baseEcran := grSeg1;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ cf proc‚dure Turbo Pascal.                                                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE setVisualPage (vPage : Byte);
BEGIN
     graph.setVisualPage(vPage);
     grVisPage := vPage;
     IF sourisOk THEN
        pageSouris(vPage);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ cf proc‚dure Turbo Pascal.                                                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ClrScr;
BEGIN
     cacheSouris;
     IF curMode = graphique THEN
     BEGIN
          ClearViewPort;
          GotoXY(1,1);
     END
     ELSE
         Crt.ClrScr;
     montreSouris;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ cf proc‚dure Turbo Pascal.                                                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE GotoXY (x, y : Byte);
BEGIN
     IF curMode = graphique THEN
     BEGIN
          grPosX := x;
          grPosY := y;
     END
     ELSE
         Crt.GotoXY(x,y);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ cf proc‚dure Turbo Pascal.                                                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION WhereX : Byte;
BEGIN
     IF curMode = graphique THEN
        WhereX := grPosX
     ELSE
         WhereX := Crt.WhereX;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ cf proc‚dure Turbo Pascal.                                                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION WhereY : Byte;
BEGIN
     IF curMode = graphique THEN
        WhereY := grPosY
     ELSE
         WhereY := Crt.WhereY;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Pr‚-Initialisation de GraphLib }
BEGIN
     AssignGraph(graf);
     Rewrite(graf);
     grClTexte := blanc;
     grClFond := noir;
     curMode := texte;
END.