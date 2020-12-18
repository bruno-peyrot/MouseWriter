UNIT TurboLib;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                                                                           }
{                                TurboLIB                                   }
{                                                                           }
{                - BibliothŠque de proc‚dures Turbo Pascal -                }
{                                                                           }
{                par Jean-Edouard & Thomas LACHAND-ROBERT                   }
{                                                                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

INTERFACE

USES
    Dos,
    Crt;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
CONST
     F1  = #59;                        { codes des touches de fonctions }
     F2  = #60;
     F3  = #61;
     F4  = #62;
     F5  = #63;
     F6  = #64;
     F7  = #65;
     F8  = #66;
     F9  = #67;
     F10 = #68;

     flchDebut   = #71;                { touches sp‚ciales du pav‚ num‚rique }
     flchHaut    = #72;
     flchPgHaut  = #73;
     flchGauche  = #75;
     flchDroite  = #77;
     flchFin     = #79;
     flchBas     = #80;
     flchPgBas   = #81;
     touchAnnl  = #83;
     toucheIns  = #82;
     toucheCorr = #8;

     carNul     = #0;
     carEsc     = #27;
     carRet     = #13;

     typeAlpha  = 1;            { types des donn‚es trait‚es }
     typeEntier = 2;
     typeReel   = 3;

     baseEcran : Word = $B000;  { segment de base de l'‚cran texte (page 0) }
     tailleEcran = 4000;        { taille de l'‚cran texte (80 x 25 x 2) }

     absX : Byte = 80;          { position maxi horizontale }
     absY : Byte = 25;          { position maxi verticale }
     xMil : Byte = 41;          { position m‚diane horizontale }

     noir      = 0;             { les seize couleurs des cartes CGA et EGA }
     bleu      = 1;
     vert      = 2;
     bleuCiel  = 3;
     rouge     = 4;
     violet    = 5;
     brun      = 6;
     grisClair = 7;
     gris      = 8;
     bleuClair = 9;
     vertClair = 10;
     bleuPale  = 11;
     orange    = 12;
     rose      = 13;
     jaune     = 14;
     blanc     = 15;

     shiftDroitMsk  = 1;             { masques de test des touches sp‚ciales }
     shiftGaucheMsk = 2;
     ctrlMsk        = 4;
     altShiftMsk    = 8;
     scrollLockMsk  = 16;
     numLockMsk     = 32;
     capsLockMsk    = 64;
     insertLMsk     = 128;

     blanche = '                                        '+   { 80 blancs }
               '                                        ';

     ligne1  = 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'+
               'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ';

     ligne2  = 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'+
               'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ';

     maxFiles  = 100;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
TYPE
    str80      = String[80];

    machineRec =
       RECORD
             tailleMemoire : Word;     { en kiloOctets jusqu'… 640Ko }
             memoireEMS    : Word;     { en kiloOctets aprŠs 640Ko }
             carteCouleur  : Boolean;  { carte couleur implant‚e ? }
             modeCouleur   : Boolean;  { en couleur au d‚marrage ? }
             nbLecteurs    : Byte;     { nb lecteurs de disquettes }
             nbParalleles  : Byte;     { nb ports // }
             nbSeries      : Byte;     { nb ports s‚rie }
             coprocessMath : Boolean;  { coprocesseur arithm‚tique ? }
       END;

    couleur  = noir..blanc;

    numAlpha = String[12];      { chaŒne : octet, entier, entier-long ou r‚el }


    ficExt     = String[3];     { 3 caractŠres d'extension de fichier }
    nomFichier = String[12];    { nom de fichier complet en MsDos }
    nomRep     = str80;         { chemin d'accŠs complet (r‚pertoire+fichier) }

    repRecPtr = ^repRec;        { record d'exploration de r‚pertoire }
    repRec    = RECORD
                      attribut   : Byte;        { attribut de lecture }
                      repertoire : nomRep;
                      masque     : nomFichier;  { filtre d'accŠs }
                      nbDossiers : Byte;        { nb dossiers trouv‚s }
                      dossiers   : ARRAY[1..maxFiles] OF nomFichier;
                      nbFichiers : Byte;        { nb fichiers trouv‚s }
                      fichiers   : ARRAY[1..maxFiles] OF nomFichier;
                      erreurES   : Byte;        { erreur rapport‚e }
                END;

    typSauv = RECORD                   { sauvegarde de paramŠtres ‚cran }
                    attr   : Byte;     { couleurs de fond et de texte }
                    curX   : Byte;     { position horizontale du curseur }
                    curY   : Byte;     { position verticale du curseur }
                    cVis   : Boolean;  { ‚tat de visibilit‚ du curseur }
              END;

    procPtr = Pointer;          { d‚finition d'un pointeur de proc‚dure }


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
VAR
   repPrg : nomRep;              { r‚pertoire de d‚marrage du programme }
   machine : machineRec;         { donn‚es sur l'environnement (HardWare) }
   curseurVis : Boolean;         { vrai si curseur visible }
   faitBip : Boolean;            { flag d'autorisation de sonorisation }
   tampon  : Pointer;            { pointeur sur l'‚cran virtuel }
   tachePrg : procPtr;           { pointeur sur une tƒche de fond }


{ outils d'usage g‚n‚ral }
PROCEDURE unBip;
PROCEDURE appelTache;
FUNCTION  etatClavier : Byte;
FUNCTION  nbOfCar (s : String;  car : Char) : Byte;
FUNCTION  compresse (phrase : str80) : str80;
FUNCTION  testeBit (numBit, octet : Byte) : Boolean;
FUNCTION  imprimantePrete : Boolean;
FUNCTION  majuscule (s : String) : String;
PROCEDURE attendAction;
FUNCTION  heureEnTexte (heure, minutes, secondes : Word) : str80;
FUNCTION  dateEnTexte (annee, moisNum, jourDuMois, jourNum : Word) : str80;

{ outils de gestion d'‚cran }
PROCEDURE centreTexte (posY : Byte;   phrase : str80);
FUNCTION  litDonnee (posX,posY,longMax,typ : Byte; parDefaut : str80) : str80;
PROCEDURE ecritEcranTexte (nomFic : str80);
PROCEDURE litEcranTexte (nomFic : str80;  efface : Boolean);
PROCEDURE cacheCurseur;
PROCEDURE montreCurseur;
PROCEDURE sauvegarde (VAR s : typSauv);
PROCEDURE restaure (s : typSauv);
PROCEDURE coulTexte (coul : couleur);
PROCEDURE coulFond (coul : couleur);
PROCEDURE inverseCar (col, ligne : Byte);
PROCEDURE inverseTexte (col, ligne, long : Byte);
PROCEDURE copieEcran;
PROCEDURE copieRamEcran;
PROCEDURE sauveRectTexte (x1, y1, x2, y2 : Byte;   donPtr : Pointer);
PROCEDURE litRectTexte (x1, y1, x2, y2 : Byte;   donPtr : Pointer);
PROCEDURE rectTexte (x1, y1, x2, y2, quel : Byte;   plein : Boolean);

{ outils de conversions et contr“les de types }
FUNCTION  estUnEntier (s : String;  long : Boolean) : Boolean;
FUNCTION  intToStr (n : Longint) : numAlpha;
FUNCTION  strToInt (s : numAlpha) : Longint;
FUNCTION  estUnReel (s : String) : Boolean;
FUNCTION  realToStr (n : REAL;   long, precision : Byte) : numAlpha;
FUNCTION  strToReal (s : numAlpha) : Real;
FUNCTION  elargi (s : String;   nb : Byte) : String;
FUNCTION  elargiADte (s : String;   nb : Byte) : String;
FUNCTION  elargiAGch (s : String;   nb : Byte) : String;

{ outils de gestion de fichiers }
FUNCTION  ficExiste (nomFic : str80) : Boolean;
FUNCTION  repExiste (repert : nomRep) : Boolean;
FUNCTION  testeFichier (nomFic : str80) : Byte;
FUNCTION  tailleFic (nomFic : str80) : Longint;
PROCEDURE listeRep (leRepert : repRecPtr);
FUNCTION  existeType (unRep : nomRep;   extension : ficExt) : Byte;


IMPLEMENTATION


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Bip sonore pour certaines alertes. La variable 'faitBip' doit ˆtre vraie. }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE unBip;
BEGIN
     IF faitBip THEN
     BEGIN
          Sound(600);
          Delay(50);
          NoSound;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{               Appel de la tƒche de fond (si elle existe).                 }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE appelTache;
BEGIN
     IF tachePrg <> NIL THEN
     Inline
     ($FF/$1E/tachePrg);      {   CALL FAR [tachePrg]   ; Tƒche programme }
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{          Teste l'‚tat courant des touches sp‚ciales du clavier.           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION etatClavier : Byte;
VAR
   regs : Registers;

BEGIN
     WITH regs DO
     BEGIN
          AH := 2;
          AL := $FF;
          Intr($16,regs);
          etatClavier := AL;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        Compte le nombre de caractŠres 'car' dans la chaine 's'.           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION nbOfCar (s : String;  car : Char) : Byte;
VAR
   il, nb : Byte;

BEGIN
     nb := 0;
     IF Length(s) > 0 THEN
        FOR il := 1 TO Length(s) DO
            IF s[il] = car THEN
               nb := Succ(nb);
     nbOfCar := nb;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Elimine les espaces … droite et … gauche de la phrase 'phrase'.      }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION compresse (phrase : str80) : str80;
VAR
   long : Byte;

BEGIN
     IF phrase <> '' THEN
     BEGIN
          long := Length(phrase);
          WHILE (phrase[long] = ' ') AND (long > 1) DO
          BEGIN
               Delete(phrase,long,1);
               long := long-1;
          END;
          WHILE (phrase[1] = ' ') AND (phrase <> '') DO
                Delete(phrase,1,1);
     END;
     compresse := phrase;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{       Teste si le bit 'numBit' (0 … 7) de l'octet 'octet' est … 1.        }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION testeBit (numBit, octet : Byte) : Boolean;
BEGIN
     testeBit := Odd(octet SHR numBit);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{       Teste si l'imprimante parallŠle est prˆte pour l'impression.        }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION imprimantePrete : Boolean;
CONST
     interImprimante = $17;
     etatImprimante = 2;

     imprimante = 0;
     pasDePapier = 5;
     prete = 4;
     erreurES = 3;

VAR
   reg : Registers;
   etat : Byte;

BEGIN
     imprimantePrete := FALSE;
     WITH reg DO
     BEGIN
          AH := etatImprimante;
          DX := imprimante;
          Intr(interImprimante,reg);
          etat := AH;
          imprimantePrete := NOT testeBit(pasDePapier,etat) AND
             NOT testeBit(erreurES,etat) AND testeBit(prete,etat);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                   La chaine 's' est renvoy‚e en majuscule.                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION majuscule (s : String) : String;
VAR
   il : Byte;

BEGIN
     IF Length(s) > 0 THEN
        FOR il := 1 TO Length(s) DO
            s[il] := UpCase(s[il]);
     majuscule := s;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                  Attend qu'une touche soit press‚e.                       }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE attendAction;
VAR
   car : Char;

BEGIN
     REPEAT
           appelTache;
     UNTIL KeyPressed;
     car := ReadKey;
     WHILE KeyPressed DO
           car := ReadKey;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Transformation de l'heure Turbo Pascal en une chaine de caractŠres.    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION heureEnTexte (heure, minutes, secondes : Word) : str80;
VAR
   hStr, mStr, sStr : String[2];

BEGIN
     hStr := intToStr(heure);
     WHILE Length(hStr) < 2 DO
           hStr := '0' + hStr;
     mStr := intToStr(minutes);
     WHILE Length(mStr) < 2 DO
           mStr := '0' + mStr;
     sStr := intToStr(secondes);
     WHILE Length(sStr) < 2 DO
           sStr := '0' + sStr;
     heureEnTexte := hStr+':'+mStr+':'+sStr;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Transformation de la date Turbo Pascal en une chaine de caractŠres.    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dateEnTexte (annee, moisNum, jourDuMois, jourNum : Word) : str80;
VAR
   jour, mois : String[10];

BEGIN
     CASE jourNum OF
          0 : jour := 'Dimanche';
          1 : jour := 'Lundi';
          2 : jour := 'Mardi';
          3 : jour := 'Mercredi';
          4 : jour := 'Jeudi';
          5 : jour := 'Vendredi';
          6 : jour := 'Samedi';
          ELSE
              jour := '?';
     END;
     CASE moisNum OF
          1 : mois := 'janvier';
          2 : mois := 'f‚vrier';
          3 : mois := 'mars';
          4 : mois := 'avril';
          5 : mois := 'mai';
          6 : mois := 'juin';
          7 : mois := 'juillet';
          8 : mois := 'aout';
          9 : mois := 'septembre';
         10 : mois := 'octobre';
         11 : mois := 'novembre';
         12 : mois := 'd‚cembre';
         ELSE
             mois := '?';
     END;
     dateEnTexte :=jour+' '+intToStr(jourDuMois)+' '+mois+' '+intToStr(annee);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{          Centre … l'‚cran la phrase 'phrase' en ligne 'posY'.             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE centreTexte (posY : Byte;   phrase : str80);
VAR
   long : Byte;

BEGIN
     long := Length(phrase) DIV 2;
     GotoXY(xMil-long,posY);
     Write(phrase);
END;



{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{  Saisie d'une donn‚e en mode texte. 'posX' et 'posY' sont les coordonn‚es }
{  de d‚but de saisie, 'longMax' est la longueur maximum du champ de saisie,}
{  'typ' est le type de donn‚e … autoriser (1=Alphanum‚rique, 2=Entier,     }
{  3=r‚el). 'parDefaut' est la valeur du champ de saisie en entr‚e. La      }
{  touche [Escape] permet d'abandonner la proc‚dure.                        }
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
   s : typSauv;

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
           Write(car);
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
        Write(Copy(phrase,1,longMax));
        compte := compte-1;
   END;

BEGIN
     sauvegarde(s);
     montreCurseur;
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
     Write(Copy(phrase,1,longMax));
     valable := FALSE;
     REPEAT
           il := 0;
           car := carNul;
           REPEAT
                 appelTache;
                 GotoXY(posX+posCurseur-1,posY);
                 Delay(10);
                 IF KeyPressed THEN
                 BEGIN
                      car := ReadKey;
                      IF (car = toucheCorr) AND (posCurseur > 1) THEN
                      BEGIN
                           posCurseur := posCurseur-1;
                           IF posCurseur <= compte THEN
                              detruitCar;
                      END;
                      IF (car = carNul) AND (KeyPressed) THEN
                      BEGIN
                           car := ReadKey;
                           GotoXY(posX+posCurseur-1,posY);
                           IF posCurseur <= longMax THEN
                              Write(phrase[posCurseur])
                           ELSE
                              Write(' ');

                           CASE car OF
                                flchDebut  : posCurseur := 1;

                                flchFin    : posCurseur := compte+1;

                                flchDroite : IF posCurseur <= longMax THEN
                                                posCurseur := posCurseur + 1;

                                flchGauche : IF posCurseur > 1 THEN
                                                posCurseur := posCurseur - 1;

                                toucheIns  :
                                IF (compte< longMax) AND (posCurseur<= compte) THEN
                                BEGIN   {Insertion}
                                     compte := compte+1;
                                     FOR il := compte DOWNTO posCurseur+1 DO
                                         phrase[il] := phrase[il-1];
                                     phrase[posCurseur] := ' ';
                                     GotoXY(posX,posY);
                                     Write(Copy(phrase,1,longMax));
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
          Write(phrase,Copy(ligne,1,longMax-compte+1))
     ELSE
          Write(parDefaut,Copy(ligne,1,longMax-Length(parDefaut)+1));
     restaure(s);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{         Sauvegarde l'ecran texte sur disque avec le nom 'nomFic'.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ecritEcranTexte (nomFic : str80);
VAR
   enregEcran : Integer;
   fichierEcran  : FILE;
   reg : Registers;

BEGIN
     Assign(fichierEcran,nomFic);
     {$I-}
     ReWrite(fichierEcran);
     {$I+}
     IF IOResult = 0 THEN
     WITH reg DO
     BEGIN
          enregEcran   := tailleEcran DIV 128;
          IF enregEcran MOD 128 <> 0 THEN
             enregEcran := Succ(enregEcran);
          BlockWrite(fichierEcran,Ptr(baseEcran,0)^,enregEcran);
          Close(fichierEcran);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                Lit l'ecran texte sur disque de nom 'nomFic'.              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE litEcranTexte (nomFic : str80;  efface : Boolean);
VAR
   enregEcran : Integer;
   fichierEcran  : FILE;
   reg : Registers;

BEGIN
     Assign(fichierEcran,nomFic);
     {$I-}
     ReSet(fichierEcran);
     {$I+}
     IF IOResult = 0 THEN
     WITH reg DO
     BEGIN
          enregEcran   := tailleEcran DIV 128;
          IF enregEcran MOD 128 <> 0 THEN
             enregEcran := Succ(enregEcran);
          BlockRead(fichierEcran,Ptr(baseEcran,0)^,enregEcran);
          Close(fichierEcran);
          IF efface THEN
             Erase(fichierEcran);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                        Cache le curseur clignotant.                       }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE cacheCurseur;
VAR
   reg : Registers;

BEGIN
     WITH reg DO
     BEGIN
          AX := $0100;
          CH := $20;
     END;
     Intr($10,reg);
     curseurVis := False;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                      Montre le curseur clignotant.                        }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE montreCurseur;
VAR
   reg : Registers;

BEGIN
     WITH reg DO
     BEGIN
          AX := $0100;
          IF machine.carteCouleur THEN
             reg.CX := $0607
          ELSE
              reg.CX := $0C0D;
     END;
     Intr($10,reg);
     curseurVis := True;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Sauvegarde certaines valeurs en cours (couleurs, position curseur, ...).  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE sauvegarde (VAR s : typSauv);
BEGIN
     WITH s DO
     BEGIN
          attr := TextAttr;
          curX := whereX;
          curY := whereY;
          cVis := curseurVis;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                restaure les valeurs se trouvant dans 's'.                  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE restaure (s : typSauv);
BEGIN
     WITH s DO
     BEGIN
          TextAttr := attr;
          Gotoxy(curX,curY);
          IF cVis THEN
             montreCurseur
          ELSE
              cacheCurseur;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{         Change la couleur du texte … 'coul' (noir … blanc).               }
{ (Si l'adaptateur est monochrome, la couleur est obligatoirement le blanc) }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE coulTexte (coul : couleur);
BEGIN
     IF machine.modeCouleur THEN
        TextColor(coul)
     ELSE
        TextColor(blanc);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{          Change la couleur du fond … 'coul' (noir … grisClair).           }
{ (Si l'adaptateur est monochrome, la couleur est obligatoirement le noir)  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE coulFond (coul : couleur);
BEGIN
     IF machine.modeCouleur THEN
        TextBackground(coul MOD 8)
     ELSE
        TextBackground(noir);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{         Inversion du caractŠre … la position texte 'posX','posY'.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE inverseCar (col, ligne : Byte);
VAR
   index : Integer;

BEGIN
     index := (160 * (ligne - 1)) + ((col - 1) * 2) + 1;
     IF machine.carteCouleur THEN
        Mem[baseEcran:index] := Mem[baseEcran:index] XOR $77
     ELSE
        Mem[baseEcran:index] := Mem[baseEcran:index] XOR $7F;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Inversion du texte commencant position 'posX','posY' et de longueur 'long'}
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE inverseTexte (col, ligne, long : Byte);
VAR
   compte : Byte;
   index : Integer;

BEGIN
     index := (160 * (ligne - 1)) + ((col - 1) * 2) + 1;
     IF machine.carteCouleur THEN
     BEGIN
          FOR compte := 0 TO long-1 DO
          BEGIN
               Mem[baseEcran:index] := Mem[baseEcran:index] XOR $77;
               index := index + 2;
          END;
     END
     ELSE
         FOR compte := 0 TO long-1 DO
         BEGIN
              Mem[baseEcran:index] := Mem[baseEcran:index] XOR $7F;
              index := index + 2;
         END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        Copie la totalit‚ de l'‚cran courant dans l'‚cran virtuel.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE copieEcran;
BEGIN
     Move(Mem[baseEcran:0],tampon^,tailleEcran);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        Copie la totalit‚ de l'‚cran virtuel dans l'‚cran courant.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE copieRamEcran;
BEGIN
     Move(tampon^,Mem[baseEcran:0],tailleEcran);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Copie la zone rectangulaire d‚finie par les deux points textes       }
{          'x1,y1' et 'x2,y2' de l'‚cran courant dans donPtr^.              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE sauveRectTexte (x1, y1, x2, y2 : Byte;   donPtr : Pointer);
VAR
   largeur, hauteur, il : Byte;

BEGIN
     IF donPtr <> NIL THEN
     BEGIN
          largeur := x2 - x1 + 1;
          hauteur := y2 - y1;
          FOR il := 0 TO hauteur DO
              Move(Mem[baseEcran:(y1+il-1)*160+(x1-1)*2],
                   Mem[Seg(donPtr^):Ofs(donPtr^)+il*largeur*2], largeur * 2);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Copie la zone rectangulaire d‚finie par les deux points textes       }
{           'x1,y1' et 'x2,y2' de donPtr^ dans l'‚cran courant.             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE litRectTexte (x1, y1, x2, y2 : Byte;   donPtr : Pointer);
VAR
   largeur, hauteur, il : Byte;

BEGIN
     IF donPtr <> NIL THEN
     BEGIN
          largeur := x2 - x1 + 1;
          hauteur := y2 - y1;
          FOR il := 0 TO hauteur DO
              Move(Mem[Seg(donPtr^):Ofs(donPtr^)+il*largeur*2],
                   Mem[baseEcran:(y1+il-1)*160+(x1-1)*2], largeur * 2);
     END;
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

BEGIN
     IF quel IN [0..2] THEN
     BEGIN
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
          IF (quel = 0) AND plein THEN
          BEGIN
               topLeft := windMin;
               botRight := windMax;
               Window(x1,y1,x2,y2);
               ClrScr;
               Window(Lo(topLeft)+1,Hi(topLeft)+1,Lo(botRight)+1,
                      Hi(botRight)+1);
          END
          ELSE
              IF (x1 <> x2) AND (y1 <> y2) THEN
              BEGIN
                   largeur := x2 - x1 - 1;
                   hauteur := y2 - y1 - 1;
                   CASE quel OF
                        0 :
                        BEGIN
                             haut := Copy(blanche,1,largeur+2);
                             IF plein THEN
                                milieu := Copy(blanche,1,largeur+2)
                             ELSE
                                milieu := ' ';
                             bas := Copy(blanche,1,largeur+2);
                        END;

                        1 :
                        BEGIN
                             haut := Concat('Ú',Copy(ligne1,1,largeur),'¿');
                             IF plein THEN
                              milieu := Concat('³',Copy(blanche,1,largeur),'³')
                             ELSE
                                milieu := '³';
                             bas := Concat('À',Copy(ligne1,1,largeur),'Ù');
                        END;

                        2 :
                        BEGIN
                             haut := Concat('É',Copy(ligne2,1,largeur),'»');
                             IF plein THEN
                              milieu := Concat('º',Copy(blanche,1,largeur),'º')
                             ELSE
                                milieu := 'º';
                             bas := Concat('È',Copy(ligne2,1,largeur),'¼');
                        END;
                   END;
                   GotoXY(x1,y1);
                   Write(haut);
                   IF plein THEN
                   BEGIN
                        FOR il := 1 TO hauteur DO
                        BEGIN
                             GotoXY(x1,y1+il);
                             Write(milieu);
                        END;
                   END
                   ELSE
                   BEGIN
                        FOR il := 1 TO hauteur DO
                        BEGIN
                             GotoXY(x1,y1+il);
                             Write(milieu);
                             GotoXy(x1+largeur+1,y1+il);
                             Write(milieu);
                        END;
                   END;
                   GotoXY(x1,y2);
                   Write(bas);
                   Gotoxy(curX,curY);
             END;
        END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        D‚termine si la chaine 's' repr‚sente un nombre entier.            }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION estUnEntier (s : String;  long : Boolean) : Boolean;
VAR
   lMax, il : Byte;
   bool : Boolean;

BEGIN
     estUnEntier := False;
     IF long THEN
        lMax := 10
     ELSE
        lMax := 5;
     IF Length(s) > 0 THEN
     BEGIN
          IF Length(s) <= lMax THEN
          BEGIN
               il := 0;
               REPEAT
                     il := il + 1;
                     bool := s[il] IN ['0'..'9','-'];
               UNTIL (NOT bool) OR (il = Length(s));
               IF bool THEN
               BEGIN
                    il := nbOfCar(s,'-');
                    IF il = 0 THEN
                       estUnEntier := True
                    ELSE
                       IF il = 1 THEN
                          estUnEntier := s[1] = '-';
               END;
          END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{       Transforme l'entier 'n' en son ‚quivalent alphanum‚rique.           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION intToStr (n : Longint) : numAlpha;
VAR
   s : numAlpha;

BEGIN
     Str(n,s);
     intToStr := s;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Transforme la chaine alphanum‚rique 's' en son ‚quivalence entiŠre.    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION strToInt (s : numAlpha) : Longint;
VAR
   i : Longint;
   result : Integer;

BEGIN
     Val(s,i,result);
     strToInt := i;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{          D‚termine si la chaine 's' repr‚sente un nombre r‚el.            }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION estUnReel (s : String) : Boolean;
VAR
   nbE, nbMoins, il : Byte;
   bool : Boolean;
   sPrim : String;

BEGIN
     estUnReel := False;
     IF Length(s) > 0 THEN
     BEGIN
          sPrim := majuscule(s);
          IF Length(sPrim) <= 12 THEN
          BEGIN
               il := 0;
               REPEAT
                     il := il + 1;
                     bool := sPrim[il] IN ['0'..'9','-','+','E'];
               UNTIL (NOT bool) OR (il = Length(sPrim));
               IF bool THEN
               BEGIN
                    nbMoins := nbOfCar(sPrim,'-');
                    nbE := nbOfCar(sPrim,'E');
                    IF nbMoins = 0 THEN
                       estUnReel := True
                    ELSE
                       IF nbMoins = 1 THEN
                           estUnReel := (s[1] = '-') OR (s[Pos('E',s)+1] = '-')
                       ELSE
                       IF nbMoins = 2 THEN
                         estUnReel := (s[1] = '-') AND (s[Pos('E',s)+1] = '-');
               END;
          END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        Transforme le r‚el 'n' en son ‚quivalent alphanum‚rique.           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION realToStr (n : REAL;   long, precision : Byte) : numAlpha;
VAR
   mantisse : Byte;
   s : numAlpha;

BEGIN
     IF long > precision THEN
        mantisse := long - precision - 1
     ELSE
        mantisse := 0;
     Str(n:mantisse:precision,s);
     s := compresse(s);
     IF (Pos('.',s) <> 0) AND (Pos('.',s) < Length(s)) THEN
        WHILE s[Length(s)] = '0' DO
              Delete(s,Length(s),1);
     s := Copy(s,1,long);
     IF s[Length(s)] = '.' THEN
        Delete(s,Length(s),1);
     realToStr := s;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Transforme la chaine alphanum‚rique 's' en son ‚quivalence r‚elle.     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION strToReal (s : numAlpha) : Real;
VAR
   valeur : Real;
   code : Integer;

BEGIN
     IF s[1] = '.' THEN
        s := '0' + s;
     Val(s,valeur,code);
     strToReal := valeur;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{  Ajoute des blancs … droite et … gauche de 's' jusqu'… la longueur 'nb'.  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION elargi (s : String;   nb : Byte) : String;
BEGIN
     IF nb > Length(s) THEN
     BEGIN
          WHILE Length(s) < nb DO
          BEGIN
               s := ' ' + s;
               IF Length(s) < nb THEN
                  s := s + ' ';
          END;
     END
     ELSE
         s := Copy(s,1,nb);
     elargi := s;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        Ajoute des blancs … droite de 's' jusqu'… la longueur 'nb'.        }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION elargiADte (s : String;   nb : Byte) : String;
BEGIN
     IF nb > Length(s) THEN
     BEGIN
          WHILE Length(s) < nb DO
                s := s + ' ';
     END
     ELSE
         s := Copy(s,1,nb);
     elargiADte := s;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        Ajoute des blancs … gauche de 's' jusqu'… la longueur 'nb'.        }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION elargiAGch (s : String;   nb : Byte) : String;
BEGIN
     IF nb > Length(s) THEN
     BEGIN
          WHILE Length(s) < nb DO
                s := ' ' + s;
     END
     ELSE
         s := Copy(s,1,nb);
     elargiAGch := s;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Teste l'existence du fichier 'nomFic'. Le nom du fichier peut ˆtre     }
{   pr‚c‚d‚ d'un chemin d'accŠs … un autre r‚pertoire que celui en cours.   }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION ficExiste (nomFic : str80) : Boolean;
VAR
   rec : SearchRec;

BEGIN
     FindFirst(nomFic,AnyFile,rec);
     ficExiste := DosError = 0;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{               Teste la pr‚sence du r‚pertoire 'repertoire'.               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION repExiste (repert : nomRep) : Boolean;
VAR
   repCourrant : nomRep;

BEGIN
     IF repert[Length(repert)] = '\' THEN
        Delete(repert,Length(repert),1);
     GetDir(0,repCourrant);
     {$I-}
     ChDir(repert);
     {$I+}
     repExiste := (IOResult = 0);
     ChDir(repCourrant);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Renvoie l'attribut du fichier sp‚cifi‚ dans l'enregistrement 'leRepert'.  }
{                                                                           }
{  L'attribut renvoy‚ sera de la forme :                                    }
{   bit = 0  :  Fichier en lecture seule.                                   }
{   bit = 1  :  Fichier cach‚.                                              }
{   bit = 2  :  Fichier systŠme.                                            }
{   bit = 3  :  Le fichier est un label de volume.                          }
{   bit = 4  :  Le fichier est un sous-r‚pertoire.                          }
{                                                                           }
{    En retour de fonction, une valeur diff‚rente de z‚ro dans DosError     }
{ indiquera que le fichier n'a pu ˆtre trouv‚.                              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION testeFichier (nomFic : str80) : Byte;
VAR
   rec : SearchRec;

BEGIN
     FindFirst(nomFic,AnyFile,rec);
     testeFichier := rec.attr;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Renvoie la taille en octets du fichier sp‚cifi‚ dans 'nomFic'.       }
{                                                                           }
{    En retour de fonction, une valeur diff‚rente de z‚ro dans DosError     }
{ indiquera que le fichier n'a pu ˆtre trouv‚.                              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION tailleFic (nomFic : str80) : Longint;
VAR
   rec : SearchRec;

BEGIN
     FindFirst(nomFic,AnyFile,rec);
     tailleFic := rec.size;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{  Liste les fichiers du disque/r‚pertoire 'repertoire' de l'enregistrement }
{  'leRepert' avec le masque 'masque'. Le nombre de fichiers trouv‚s est    }
{  dans 'nbFichiers'. Les noms des fichiers dans 'fichiers[1..nbFichiers]'. }
{  Le nombre de dossiers dans 'nbDossiers' tandis que leurs noms sont dans  }
{  'dossiers[1..nbDossiers]'.                                               }
{                                                                           }
{  Les codes d'erreurs sont retourn‚s par 'erreurES' comme suit:            }
{   erreurES = 0  :  Pas d'erreur.                                          }
{   erreurES = 1  :  R‚pertoire non trouv‚.                                 }
{   erreurES = 2  :  Pas de fichiers trouv‚s.                               }
{   erreurES = 3  :  Nombre de fichiers trouv‚s sup‚rieur … 'maxFiles'.     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE listeRep (leRepert : repRecPtr);
VAR
   index, il : Byte;
   rec : SearchRec;
   bad : Boolean;

BEGIN
     WITH leRepert^ DO
     BEGIN
          nbFichiers := 0;
          nbDossiers := 0;
          IF repertoire[Length(repertoire)] <> '\' THEN
             repertoire := repertoire + '\';
          IF NOT repExiste(repertoire) THEN
             erreurES := 1
          ELSE
          BEGIN
             FindFirst(repertoire+masque,attribut,rec);
             IF DosError = 0 THEN
             BEGIN
                IF (rec.attr AND attribut = rec.attr) THEN
                BEGIN
                     IF rec.attr AND Directory = 0 THEN   { fichier }
                     BEGIN
                          nbFichiers := nbFichiers + 1;
                          fichiers[nbFichiers] := rec.Name;
                     END
                     ELSE
                         IF (rec.Name <> '.') AND (rec.Name <> '..') THEN
                         BEGIN
                              nbDossiers := nbDossiers + 1;
                              dossiers[nbDossiers] := rec.Name;
                         END;
                END;
                REPEAT
                    FindNext(rec);      { bug dans FindNext (rec.attr ignor‚) }
                    IF rec.attr AND attribut = rec.attr THEN { alors on teste }
                    BEGIN
                         bad := (nbDossiers = maxFiles) OR
                                (nbFichiers = maxFiles) OR (DosError <> 0);
                         IF NOT bad THEN
                            IF rec.attr AND Directory = 0 THEN { fichier }
                            BEGIN
                                 nbFichiers := nbFichiers + 1;
                                 fichiers[nbFichiers] := rec.Name;
                            END
                            ELSE
                               IF (rec.Name <> '.') AND (rec.Name <> '..') THEN
                               BEGIN
                                    nbDossiers := nbDossiers + 1;
                                    dossiers[nbDossiers] := rec.Name;
                               END;
                    END
                    ELSE
                        bad := DosError <> 0;
                UNTIL bad;
                IF DosError = 0 THEN
                   erreurES := 3
                ELSE
                   erreurES := 0;
             END
             ELSE
                 erreurES := 2;
          END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Donne le nombre de fichiers d'extension 'extension' dans le r‚pertoire    }
{ 'unRep'.                                                                  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION existeType (unRep : nomRep;   extension : ficExt) : Byte;
VAR
   rec : SearchRec;
   nb : Byte;

BEGIN
     nb := 0;
     IF NOT (unRep[Length(unRep)] = '\') THEN
        unRep := unRep + '\';
     FindFirst(unRep+'*.'+extension,anyFile,rec);
     IF DosError = 0 THEN
     REPEAT
           nb := nb + 1;
           FindNext(rec);
     UNTIL DosError <> 0;
     existeType := nb;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{               D‚termine l'environnement de la machine.                    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE environnement;
VAR
   reg : Registers;

BEGIN
     FillChar(machine,SizeOf(machineRec),#0);
     WITH machine DO
          WITH reg DO
          BEGIN
               Intr($11,reg);
               carteCouleur := (AL AND $30 <> $30);
               IF carteCouleur THEN
                   baseEcran := $B800
               ELSE
                   baseEcran := $B000;
               modeCouleur := (Mem[$40:$49] IN [1,3,4]);
               nbParalleles := (AH AND $C0) Shr 6;
               IF (AL AND $C0) Shr 6 = 0 THEN
                  nbLecteurs := 1
               ELSE
                   IF ((AL AND $C0) Shr 6 = 1) AND ((AL AND 1) = 1) THEN
                      nbLecteurs := 2;
               nbSeries := (AH AND $0E) Shr 1;
               coprocessMath := (AL AND 2 = 2);
               Intr($12,reg);
               tailleMemoire := AX;
               AH := $88;
               Intr($15,reg);
               memoireEMS := AX;
          END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Pr‚-Initialisation de TurboLib }
BEGIN
     repPrg := paramStr(0);
     IF Pos(':',repPrg) > 0 THEN
     BEGIN
          repPrg := paramStr(0);
          REPEAT
                Delete(repPrg,Length(repPrg),1);
          UNTIL repPrg[Length(repPrg)] IN [':','\'];
     END
     ELSE
         GetDir(0,repPrg);
     IF repPrg[Length(repPrg)] <> '\' THEN
        repPrg := repPrg + '\';
     environnement;
     curseurVis := True;
     GetMem(tampon,tailleEcran);    { allocation de la zone d'‚cran virtuel }
     faitBip := True;
     tachePrg := NIL;               { pas de tƒche programme en cours }
END.