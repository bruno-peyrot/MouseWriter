UNIT TurboFtr;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                                                                           }
{                                TurboFTR                                   }
{                                                                           }
{         - Gestion de fenˆtres en mode texte pour Turbo Pascal -           }
{                                                                           }
{                par Jean-Edouard & Thomas LACHAND-ROBERT                   }
{                                                                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

INTERFACE

USES
    Dos,
    Crt,
    TurboLib,
    TurboTxt;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
CONST
     coulAlertes   : couleur = rouge;  { couleur de fond des alertes }
     coulDialogues : couleur = bleu;   { couleur de fond des dialogues }
     coulBoutons   : couleur = gris;   { couleur de fond des boutons }
     coulTextes    : couleur = blanc;  { couleur du texte des dialogues }

     tempAlertes : Byte = 0;           { temporisation des alertes }

     normalMsk   = 7;     { saisie normale des choix }
     contourMsk  = 1;     { saisie des choix sans dessin des contours }
     recouvreMsk = 2;     { saisie des choix sans sauvegarde }
     ombreMsk    = 4;     { choix dans une fenˆtre ombr‚e }

     maxFic = 100;        { nb maxi de fichiers dans un r‚pertoire }


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
TYPE
    typDialog = (bord1, bord2, ombre1, ombre2);

    typDlog = RECORD    { d‚finition d'une fenˆtre de dialogue }
                    DTyp     : typDialog;  { type du dialogue }
                    DRect    : rectTxt;    { contour du dialogue }
                    titre    : str80;      { son titre (facultatif) }
                    clTexte  : couleur;    { couleur du titre et du bord }
                    clFond   : couleur;    { couleur du fond }
                    taille   : Word;       { taille des donn‚es recouvertes }
                    donnees  : Pointer;    { donn‚es recouvertes }
              END;

    typChoix = ARRAY [1..100] OF String[40]; { une liste de choix }

    ctrlChoixPtr = ^typCtrlChoix;            { contr“le d'un choix }
    typCtrlChoix =
       RECORD
             action     : (prepare, traite, ferme);  { actions possibles }
             choixCtrl  : Byte;      { modificateur d'ex‚cution }
             cmd        : Char;      { commande recue de l'utilisateur }
             posX       : Byte;      { position horizontale du choix }
             posY       : Byte;      { position verticale du choix }
             nbEcrits   : Integer;   { nb de choix ds la fenˆtre }
             nbMax      : Integer;   { nb de choix maxi }
             result     : Integer;   { choix effectu‚ }
             carCtrl    : Set Of Char;  { caractŠres acceptables }
             don        : Array [1..1000] OF ^str80 ;       { choix }
             contour    : rectTxt;   { rectangle englobant les choix }
             posHaut    : Integer;   { premier choix affich‚ }
             select     : Integer;   { choix s‚lectionn‚ }
             nouvSelect : Integer;   { usage interne }
             taille     : Word;      { taille des donn‚es recouvertes }
             donnees    : Pointer;   { donn‚es recouvertes }
       END;

    typVitesse = (rapide, moyenne, lente);   { vitesse des effets visuels }

    typEffet = (pousseAGauche,pousseADroite,pousseEnBas,pousseEnHaut,
             ouvreVert,fermeVert,ouvreHoriz,fermeHoriz,ouvreZoom,fermeZoom);



PROCEDURE centreRect (VAR r : rectTxt;  lInt, hInt : Byte);
PROCEDURE ouvreDialogue (VAR leDlog : typDlog);
PROCEDURE fermeDialogue (VAR leDlog : typDlog);
PROCEDURE alerte (titre : str80);
FUNCTION  dialogueTexte (titre, defaut : str80;  longMax : Byte) : str80;
FUNCTION  dialogueNbr (titre : str80;   min, max, defaut : Integer) : Integer;
FUNCTION  dialogueReel (titre : str80;   min, max, defaut : Real) : Real;
FUNCTION  dialogueBout (titre, bout1, bout2 : str80) : Boolean;
FUNCTION  choix (posX, posY, nbEcrits, nbMax : Byte; VAR result : Byte;
          donnees : typChoix) : Boolean;
FUNCTION  choixFichier (posX, posY : Byte;  VAR repert : nomRep;
          VAR fichier : nomFichier;   titre : str80) : Boolean;
PROCEDURE effetVisuel (scrPtr : Pointer;   effet : typEffet;
          vitesse : typVitesse);


IMPLEMENTATION


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{            Initialise le rectangle 'r' aux valeurs donn‚es.               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE initRect (VAR r : rectTxt;  y1, x1, y2, x2 : Byte);
BEGIN
     r.x1 := x1;
     r.y1 := y1;
     r.x2 := x2;
     r.y2 := y2;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Calcule dans 'r' un rectangle centr‚ de largeur 'lInt' et hauteur 'hInt'. }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE centreRect (VAR r : rectTxt;  lInt, hInt : Byte);
VAR
   demiLargeur, demiHauteur : Byte;

BEGIN
     IF lInt < 1 THEN
        lInt := 1;
     IF lInt > absX-2 THEN
        lInt := absX-2;
     IF hInt < 1 THEN
        hInt := 1;
     IF hInt > 23 THEN
        hInt := 23;
     demiLargeur := lInt DIV 2;
     demiHauteur := hInt DIV 2;
     WITH r DO
     BEGIN
          x1 := xMil - demiLargeur - 1;
          IF x1 < 1 THEN
             x1 := 1;
          y1 := 12 - demiHauteur;
          IF y1 < 1 THEN
             y1 := 1;
          x2 := x1 + lInt + 1;
          y2 := y1 + hInt + 1;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{           Ouvre la fenˆtre de dialogue d‚finie dans 'leDlog'.               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ouvreDialogue (VAR leDlog : typDlog);
VAR
   attribut, oldX : Byte;
   rDon : rectTxt;

BEGIN
     WITH leDlog DO
          WITH rDon DO
          BEGIN
               IF DTyp IN [ombre1,ombre2] THEN
                  initRect(rDon,DRect.y1,DRect.x1,DRect.y2+1,DRect.x2+1)
               ELSE
                  rDon := DRect;
               IF (y2 > y1+1) AND (x2 > x1+1) THEN
               BEGIN
                    attribut := TextAttr;  { on ne pr‚serve que les couleurs }
                    taille := (x2 - x1 + 1) * (y2 - y1 + 1) * 2;
                    GetMem(donnees,taille);
                    sauveRectTexte(x1,y1,x2,y2,donnees);
                    coulFond(clFond);
                    coulTexte(clTexte);
                    CASE DTyp OF
                         bord1 : rectTexte(x1,y1,x2,y2,1,True);
                         bord2 : rectTexte(x1,y1,x2,y2,2,True);
                         ombre1,
                         ombre2 :
                         BEGIN
                              coulFond(noir);
                              rectTexte(x1+1,y1+1,x2,y2,0,True);
                              coulFond(clFond);
                             rectTexte(x1,y1,x2-1,y2-1,Ord(DTyp=ombre2)+1,True)
                         END;
                    END;
                    oldX := xMil;
                    xMil := x1 + ((x2 - x1 + 1) DIV 2);
                    IF (Length(titre) > 0) AND (Length(titre) < x2-x1-1) THEN
                       centreTexte(y1,' '+titre+' ');
                    xMil := oldX;
                    TextAttr := attribut;
               END;
          END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                   Ferme la fenˆtre de dialogue 'leDlog'.                    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE fermeDialogue (VAR leDlog : typDlog);
VAR
   rDon : rectTxt;

BEGIN
     WITH leDlog DO
          IF (taille > 0) AND (donnees <> NIL) THEN
          BEGIN
               IF DTyp IN [ombre1,ombre2] THEN
                  initRect(rDon,DRect.y1,DRect.x1,DRect.y2+1,DRect.x2+1)
               ELSE
                  rDon := DRect;
               WITH rDon DO
                    litRectTexte(x1,y1,x2,y2,donnees);
               FreeMem(donnees,Taille);
               donnees := NIL;
          END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Message d'alerte. Si 'tempAlertes' vaut 0, une touche de validation est     }
{ attendue, sinon, sa valeur d‚fini la dur‚e de l'alerte.                     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE alerte (titre : str80);
VAR
   dlg : typDlog;
   s : typSauv;

BEGIN
     IF titre <> '' THEN
     BEGIN
          sauvegarde(s);
          cacheCurseur;
          centreRect(dlg.DRect,Length(titre)+2,3);
          WITH dlg DO
          BEGIN
               titre := '';
               DTyp := ombre2;
               clFond := coulAlertes;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulAlertes);
          coulTexte(coulTextes);
          centreTexte(13,titre);
          IF faitBip THEN
          BEGIN
               Sound(600);
               Delay(50);
               Sound(400);
               Delay(50);
               NoSound;
          END;
          IF tempAlertes <> 0 THEN
             Delay(tempAlertes * Length(titre))
          ELSE
             attendAction;
          fermeDialogue(dlg);
          restaure(s);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{  Saisie d'une donn‚e alphanum‚rique de longueur 'longMax' dans un dialogue. }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dialogueTexte (titre, defaut : str80;  longMax : Byte) : str80;
VAR
   dlg : typDlog;
   cmd : Char;
   s : typSauv;

BEGIN
     IF (Length(titre)<76) AND (Length(defaut)<=longMax) AND (longMax<76) THEN
     BEGIN
          sauvegarde(s);
          IF Length(titre) > longMax THEN
             centreRect(dlg.DRect,Length(titre)+2,3)
          ELSE
             centreRect(dlg.DRect,LongMax+2,3);
          WITH dlg DO
          BEGIN
               titre := '';
               DTyp := ombre2;
               clFond := coulDialogues;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulDialogues);
          coulTexte(coulTextes);
          centreTexte(12,titre);
          dialogueTexte := litDonnee(xMil - longMax DIV 2,14,longMax,1,defaut);
          fermeDialogue(dlg);
          restaure(s);
     END
     ELSE
         dialogueTexte := defaut;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{          Saisie d'une donn‚e entiŠre comprise entre 'min' et 'max'.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dialogueNbr (titre : str80;   min, max, defaut : Integer) : Integer;
VAR
   strg, maxStr, defautStr : numAlpha;
   strVal, long : Integer;
   cmd : Char;
   dlg : typDlog;
   s : typSauv;

BEGIN
     IF (Length(titre) < 76) AND (min < max) AND
        (defaut >= min) AND (defaut <= max) THEN
     BEGIN
          sauvegarde(s);
          maxStr := intToStr(max);
          long := Length(maxStr);
          IF Length(titre) > long THEN
             centreRect(dlg.DRect,Length(titre)+2,3)
          ELSE
             centreRect(dlg.DRect,Long+2,3);
          WITH dlg DO
          BEGIN
               titre := '';
               DTyp := ombre2;
               clFond := coulDialogues;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulDialogues);
          coulTexte(coulTextes);
          centreTexte(12,titre);
          defautStr := intToStr(defaut);
          REPEAT
                strg := litDonnee(xMil - long DIV 2,14,long,2,defautStr);
                strVal := strToInt(strg);
                IF (strVal < min) OR (strVal > max) THEN
                   strg := '';
          UNTIL strg <> '';
          dialogueNbr := strVal;
          fermeDialogue(dlg);
          restaure(s);
     END
     ELSE
         dialogueNbr := defaut;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{           Saisie d'une donn‚e r‚elle comprise entre 'min' et 'max'.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dialogueReel (titre : str80;   min, max, defaut : Real) : Real;
VAR
   strg, defautStr : numAlpha;
   strVal : Real;
   cmd : Char;
   dlg : typDlog;
   s : typSauv;

BEGIN
     IF (Length(titre) < 76) AND (min < max) AND
        (defaut >= min) AND (defaut <= max) THEN
     BEGIN
          sauvegarde(s);
          IF Length(titre) > 12 THEN
             centreRect(dlg.DRect,Length(titre)+2,3)
          ELSE
             centreRect(dlg.DRect,14,3);
          WITH dlg DO
          BEGIN
               titre := '';
               DTyp := ombre2;
               clFond := coulDialogues;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulDialogues);
          coulTexte(coulTextes);
          centreTexte(12,titre);
          defautStr := realToStr(defaut,12,2);
          REPEAT
                strg := litDonnee(xMil - 6,14,12,typeReel,defautStr);
                strVal := strToReal(strg);
                IF (strVal < min) OR (strVal > max) THEN
                   strg := '';
          UNTIL strg <> '';
          dialogueReel := strVal;
          fermeDialogue(dlg);
          restaure(s);
     END
     ELSE
         dialogueReel := defaut;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{  Dessine un dialogue comportants deux boutons 'bout1' et 'bout2' de choix.  }
{   (le choix 1 est retourn‚ par d‚faut par l'appui de la touche d'entr‚e.)   }
{  Une valeur bool‚enne vraie en retour indique le choix du bouton 1.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dialogueBout (titre, bout1, bout2 : str80) : Boolean;
VAR
   long, longBis : Integer;
   r1, r2 : rectTxt;
   bouton1, etatCurseur : Boolean;
   dlg : typDlog;
   car : Char;
   s : typSauv;

BEGIN
     sauvegarde(s);
     cacheCurseur;
     WHILE Length(bout1) < Length(bout2) DO
           bout1 := Concat(' ',bout1,' ');
     IF Length(bout1) > 34 THEN
        bout1 := Copy(bout1,1,34);
     IF Length(bout2) > 34 THEN
        bout2 := Copy(bout2,1,34);
     long := Length(bout1)+2;
     WHILE (long * 2) + 4 > Length(titre) DO
           titre := Concat(' ',titre,' ');
     centreRect(dlg.DRect,Length(titre)+2,5);
     WITH dlg DO
     BEGIN
          titre := '';
          DTyp := ombre2;
          clFond := coulDialogues;
          clTexte := coulTextes;
     END;
     ouvreDialogue(dlg);
     coulFond(coulDialogues);
     coulTexte(coulTextes);
     centreTexte(11,titre);
     longBis := long + (long DIV 2);
     IF longBis > Length(titre) DIV 2 THEN
        longBis := Length(titre) DIV 2;
     coulFond(coulBoutons);
     WITH r1 DO
     BEGIN
          x1 := xMil-longBis;
          y1 := 13;
          x2 := x1 + long + 1;
          y2 := 15;
          rectTexte(x1,y1,x2,y2,2,TRUE);
     END;
     WITH r2 DO
     BEGIN
          x1 := xMil-1+longBis-long;
          y1 := 13;
          x2 := x1 + long + 1;
          y2 := 15;
          rectTexte(x1,y1,x2,y2,1,TRUE);
     END;
     GotoXY(xMil+2-longBis,14);
     Write(bout1);
     GotoXY(xMil+longBis- (long+ Length(bout2)) DIV 2,14);
     Write(bout2);
     bouton1 := TRUE;
     inverseTexte(xMil+1-longBis,14,long);
     REPEAT
           appelTache;
           IF KeyPressed THEN
           BEGIN
                car := ReadKey;
                IF (car = #0) AND KeyPressed THEN
                BEGIN
                     car := ReadKey;
                     CASE car OF

                          flchDroite :
                          BEGIN
                               inverseTexte(xMil+longBis-long,14,long);
                               bouton1 := NOT bouton1;
                               inverseTexte(xMil+1-longBis,14,long);
                          END;

                          flchGauche :
                          BEGIN
                               inverseTexte(xMil+1-longBis,14,long);
                               bouton1 := NOT bouton1;
                               inverseTexte(xMil+longBis-long,14,long);
                          END;

                     END;
                END;
           END;
     UNTIL car = carRet;
     dialogueBout := bouton1;
     Delay(100);
     fermeDialogue(dlg);
     restaure(s);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                Choix contr“l‚ d'un texte dans une liste.                  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE actChoix (ctrlChoix : ctrlChoixPtr);
VAR
   larg : Byte;
   il : Word;
   ok, change, tropDeFic : Boolean;
   nulTexte : str80;
   car : Char;
   s : typSauv;

PROCEDURE vaBas;
BEGIN
     IF ctrlChoix^.posHaut <= ctrlChoix^.nbMax - ctrlChoix^.nbEcrits THEN
     BEGIN
          ctrlChoix^.posHaut := ctrlChoix^.posHaut+1;
          change := TRUE;
          ctrlChoix^.select := ctrlChoix^.nbEcrits;
          ctrlChoix^.nouvSelect := 0;
     END
     ELSE
         unBip;
END;

PROCEDURE vaHaut;
BEGIN
     IF ctrlChoix^.posHaut > 1 THEN
     BEGIN
          ctrlChoix^.posHaut := ctrlChoix^.posHaut-1;
          change := TRUE;
          ctrlChoix^.select := 1;
          ctrlChoix^.nouvSelect := 0;
     END
     ELSE
         unBip;
END;

PROCEDURE vaPgBas;
BEGIN
     IF ctrlChoix^.posHaut + ctrlChoix^.nbEcrits <= ctrlChoix^.nbMax THEN
     BEGIN
          ctrlChoix^.posHaut := ctrlChoix^.posHaut+ctrlChoix^.nbEcrits;
          change := TRUE;
          ctrlChoix^.nouvSelect := ctrlChoix^.select;
          IF ctrlChoix^.nouvSelect + ctrlChoix^.posHaut > ctrlChoix^.nbMax THEN
            ctrlChoix^.nouvSelect := ctrlChoix^.nbMax - ctrlChoix^.posHaut + 1;
     END
     ELSE
         ctrlChoix^.nouvSelect := ctrlChoix^.nbMax-ctrlChoix^.posHaut+1;
END;

PROCEDURE vaPgHaut;
BEGIN
     IF ctrlChoix^.posHaut - ctrlChoix^.nbEcrits >= 1 THEN
     BEGIN
          ctrlChoix^.posHaut := ctrlChoix^.posHaut-ctrlChoix^.nbEcrits;
          change := TRUE;
          ctrlChoix^.nouvSelect := ctrlChoix^.select;
     END
     ELSE
       IF ctrlChoix^.posHaut > 1 THEN
       BEGIN
          IF ctrlChoix^.select + ctrlChoix^.posHaut > ctrlChoix^.nbEcrits THEN
              ctrlChoix^.nouvSelect := ctrlChoix^.posHaut + ctrlChoix^.select -
              ctrlChoix^.nbEcrits
          ELSE
              ctrlChoix^.nouvSelect := 1;
          ctrlChoix^.posHaut := 1;
          change := TRUE;
       END
       ELSE
           ctrlChoix^.nouvSelect := 1;
END;

BEGIN
     WITH ctrlChoix^ DO
     BEGIN
     tropDeFic := nbMax > nbEcrits;
     CASE action OF
       prepare :
       BEGIN
         sauvegarde(s);
         don[1]^ := don[1]^;
         larg := 0;
         FOR il := 1 TO nbMax DO
             IF Length(don[il]^) > larg THEN
                larg := Length(don[il]^);
         IF choixCtrl AND ombreMsk <> 0 THEN
            larg := larg + 3
         ELSE
             larg := larg + 2;
         IF Odd(larg) THEN
            larg := larg + 1;
         IF posY + nbEcrits + 1 <= absY THEN
            contour.y1 := posY
         ELSE
            contour.y1 := absY - nbEcrits - 1;
         IF choixCtrl AND ombreMsk <> 0 THEN
         BEGIN
          contour.y2 := contour.y1+nbEcrits+2;
           IF contour.y2 > absY THEN
           BEGIN
                contour.y2 := Pred(contour.y2);
                contour.y1 := Pred(contour.y1);
           END;
         END
         ELSE
          contour.y2 := contour.y1+nbEcrits+1;
         IF posX + larg + 1 <= absX THEN
            contour.x1 := posX
         ELSE
            contour.x1 := absX - larg - 1;
         contour.x2 := contour.x1 + larg + 1;
         nulTexte := Copy(blanche,1,larg);
         IF choixCtrl AND recouvreMsk <> 0 THEN
            WITH contour DO
            BEGIN
                 taille := (x2 - x1 + 1) * (y2 - y1 + 1) * 2;
                 GetMem(donnees,taille);
                 sauveRectTexte(x1,y1,x2,y2,donnees);
            END;
         IF choixCtrl AND contourMsk <> 0 THEN
            IF choixCtrl AND ombreMsk = 0 THEN
               rectTexte(contour.x1,contour.y1,contour.x2,contour.y2,2,TRUE)
            ELSE
                WITH contour DO
                BEGIN
                     larg := TextAttr;
                     coulFond(noir);
                     rectTexte(x1+1,y1+1,x2,y2,0,TRUE);
                     TextAttr := larg;
                     rectTexte(x1,y1,x2-1,y2-1,2,TRUE);
                END;
         IF (result > nbMax) OR (result < 1) THEN
            result := 1;
         IF tropDeFic AND (result > nbEcrits) THEN
         BEGIN
              posHaut := (result DIV nbEcrits) * nbEcrits;
              select := (result MOD nbEcrits) + 1;
              nouvSelect := select;
         END
         ELSE
         BEGIN
              posHaut := 1;
              select := result;
              nouvSelect := result;
         END;
         restaure(s);
       END;

       traite :
       BEGIN
            sauvegarde(s);
            cacheCurseur;
            IF choixCtrl AND ombreMsk <> 0 THEN
               larg := contour.x2 - contour.x1 - 2
            ELSE
                larg := contour.x2 - contour.x1 - 1;
            nulTexte := Copy(blanche,1,larg);
            ok := FALSE;
            REPEAT
                  FOR il := 1 TO nbEcrits DO
                  BEGIN
                       GotoXY(contour.x1+1,il+contour.y1);
                       Write(nulTexte);
                       IF posHaut-1+il <= nbMax THEN
                       BEGIN
                            GotoXY(contour.x1+2,il+contour.y1);
                            Write(don[posHaut-1+il]^);
                       END;
                       IF choixCtrl AND contourMsk <> 0 THEN
                       BEGIN
                            Gotoxy(contour.x1+(larg DIV 2),contour.y1);
                            IF posHaut > 1 THEN
                               Write(#30,#30)
                            ELSE
                               Write(#205,#205);
                            Gotoxy(contour.x1+(larg DIV 2),contour.y1+1+
                                   nbEcrits);
                            IF posHaut+nbEcrits <= nbMax THEN
                               Write(#31,#31)
                            ELSE
                               Write(#205,#205);
                       END;
                  END;
                  IF select <> 0 THEN
                     inverseTexte(contour.x1+1,select+contour.y1,larg);
                  change := FALSE;
                  REPEAT
                        appelTache;
                        IF KeyPressed THEN
                        BEGIN
                             car := ReadKey;
                             IF (car = carNul) AND KeyPressed THEN
                             BEGIN
                                  car := ReadKey;
                                  ok := car IN carCtrl;
                                  CASE car OF
                                       flchHaut :
                                       IF tropDeFic AND (select = 1) THEN
                                          vaHaut
                                       ELSE
                                           IF (nouvSelect-1+posHaut > 1) THEN
                                              nouvSelect := select - 1;
                                       flchBas :
                                       IF tropDeFic AND (select=nbEcrits) THEN
                                          vaBas
                                       ELSE
                                           IF (nouvSelect-1+posHaut<nbMax) THEN
                                              nouvSelect := select + 1;
                                       flchPgBas  : vaPgBas;
                                       flchPgHaut : vaPgHaut;
                                  END;
                                  IF nouvSelect <> 0 THEN
                                  BEGIN
                                       IF (select <> 0) AND
                                          (nouvSelect <> select) THEN
                                          inverseTexte(contour.x1+1,select+
                                          contour.y1,larg);
                                       IF select <> nouvSelect THEN
                                        inverseTexte(contour.x1+1,nouvSelect+
                                        contour.y1,larg);
                                       select := nouvSelect;
                                  END
                                  ELSE
                                      nouvSelect := select;
                             END
                             ELSE
                                 ok := car IN carCtrl;
                        END;
                  UNTIL change OR ok;
            UNTIL ok;
            cmd := car;
            result := select+posHaut-1;
            restaure(s);
       END;

       ferme :
       BEGIN
            IF choixCtrl AND recouvreMsk <> 0 THEN
               WITH contour DO
               BEGIN
                    litRectTexte(x1,y1,x2,y2,donnees);
                    FreeMem(donnees,taille);
               END;
       END;
     END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{           Choix d'un texte dans une liste de type 'typChoix'.             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION choix (posX, posY, nbEcrits, nbMax : Byte; VAR result : Byte;
               donnees : typChoix) : Boolean;
VAR
   ctrlC : ctrlChoixPtr;
   il : Byte;

BEGIN
     IF (nbEcrits < absY-2) AND (nbMax <= 100) THEN
     BEGIN
          New(ctrlC);
          ctrlC^.posX := posX;
          ctrlC^.posY := posY;
          ctrlC^.nbEcrits := nbEcrits;
          ctrlC^.nbMax := 0;
          ctrlC^.result := result;
          ctrlC^.carCtrl := [carRet,carEsc];
          REPEAT
                ctrlC^.nbMax := ctrlC^.nbMax + 1;
                IF donnees[ctrlC^.nbMax] <> '' THEN
                BEGIN
                     New(ctrlC^.don[ctrlC^.nbMax]);
                     ctrlC^.don[ctrlC^.nbMax]^ := donnees[ctrlC^.nbMax];
                END;
          UNTIL (donnees[ctrlC^.nbMax] = '') OR (ctrlC^.nbMax = nbMax);
          IF ctrlC^.nbMax < nbMax THEN
             ctrlC^.nbMax := ctrlC^.nbMax - 1;
          ctrlC^.choixCtrl := normalMsk;
          ctrlC^.action := prepare;
          actChoix(ctrlC);
          ctrlC^.action := traite;
          REPEAT
                actChoix(ctrlC);
          UNTIL (ctrlC^.cmd IN [carEsc,carRet]);
          FOR il := 1 TO ctrlC^.nbMax DO
              Dispose(ctrlC^.don[il]);
          IF ctrlC^.cmd = carRet THEN
          BEGIN
               result := ctrlC^.result;
               choix := True;
          END
          ELSE
              choix := False;
          ctrlC^.action := ferme;
          actChoix(ctrlC);
          Dispose(ctrlC);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{     Choix d'un fichier du r‚pertoire 'repert' et de masque 'fichier'.     }
{   Titre est le titre de la fenˆtre de choix affich‚e en 'posX','posY'.    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION choixFichier (posX, posY : Byte;  VAR repert : nomRep;
                      VAR fichier : nomFichier;   titre : str80) : Boolean;
VAR
   nbFic, largeur, il : Integer;
   long, haut, bas, droite, gauche, select, xChoix, yChoix : Byte;
   afficheRep, fin : Boolean;
   data : typChoix;
   lastRep, temp : nomFichier;
   dlg : TypDlog;
   s : typSauv;


FUNCTION litDir : Boolean;
VAR
   leRepert : repRecPtr;
   nbRep, il, jl : Byte;
   temp : String[20];

BEGIN
     IF repert[Length(repert)] = '\' THEN
        Delete(repert,Length(repert),1);
     nbFic := 1;
     select := 1;
     il := Length(repert);
     WHILE NOT (repert[il] IN ['\',':']) DO
           il := il - 1;
     IF repert[il] = ':' THEN
        data[1] := ' ' + repert
     ELSE
        data[1] := #17 + ' '+ Copy(repert,il,Length(repert)-il+1);
     data[1] := elargiADte(data[1],16);
     New(leRepert);
     WITH leRepert^ DO
     BEGIN
          attribut := Directory+ReadOnly;
          repertoire := repert;
          masque := '*.*';
     END;
     listeRep(leRepert);
     WITH leRepert^ DO
     IF (erreurES <> 1) AND (nbDossiers > 0) THEN
     BEGIN
          FOR il := 1 TO nbDossiers DO
          BEGIN
               select := select + 1;
               nbFic := nbFic + 1;
               data[nbFic] := #16 + ' ' + dossiers[il];
          END;
          IF nbDossiers > 1 THEN
             FOR il := 2 TO nbDossiers DO
                 FOR jl := il+1 TO nbDossiers + 1 DO
                     IF data[jl] < data[il] THEN
                     BEGIN
                          temp := data[il];
                          data[il] := data[jl];
                          data[jl] := temp;
                     END;
     END;
     nbRep := leRepert^.nbDossiers;
     IF fichier <> '*.' THEN
     BEGIN
          WITH leRepert^ DO
          BEGIN
               attribut := Archive;
               repertoire := repert;
               masque := fichier;
          END;
          listeRep(leRepert);
          WITH leRepert^ DO
          IF erreurES <> 1 THEN
          BEGIN
               nbDossiers := nbRep;
               IF nbFichiers > 0 THEN
               BEGIN
                    FOR il := 1 TO nbFichiers DO
                        IF nbFic < maxFic THEN
                        BEGIN
                             nbFic := nbFic + 1;
                             data[nbFic] := '  ' + fichiers[il];
                        END;
                    IF nbFichiers > 1 THEN
                       FOR il := nbFic DOWNTO nbDossiers + 3 DO
                            FOR jl := il-1 DOWNTO nbDossiers + 2 DO
                                IF data[jl] > data[il] THEN
                                BEGIN
                                     temp := data[il];
                                     data[il] := data[jl];
                                     data[jl] := temp;
                                END;
                    select := select + 1;
               END
               ELSE
               BEGIN
                    IF (nbDossiers > 0) AND (lastRep <> '') THEN
                    BEGIN
                         il := 1;
                         REPEAT
                               il := il + 1;
                         UNTIL (data[il] = lastRep) OR (il = nbDossiers + 1);
                         IF data[il] = lastRep THEN
                            select := il;
                    END;
               END;
          END
          ELSE
              litDir := False;
     END
     ELSE
     BEGIN
          FOR il := nbFic DOWNTO 1 DO
              data[il+1] := data[il];
          nbFic := Succ(nbFic);
          select := Succ(select);
          temp := '< Valider >';
          data[1] := temp;
     END;
     Dispose(leRepert);
END;

FUNCTION testeDrive (drive : Char) : Boolean;
VAR
   s : SearchRec;
   p : Pointer;
   reg : Registers;

BEGIN
     IF NOT (drive IN ['A','B']) THEN
     BEGIN
          FindFirst(drive+':*.*',AnyFile,s);
          testeDrive := DosError = 0;
     END
     ELSE
     WITH reg DO
     BEGIN
          GetMem(p,512);
          AH := 2;
          DL := Ord(drive) - Ord('A');
          DH := 0;
          CH := 0;
          CL := 1;
          AL := 1;
          ES := Seg(p^);
          BX := Ofs(p^);
          Intr($13,reg);
          testeDrive := AH IN [0,6];
          FreeMem(p,512);
     END;
END;

PROCEDURE changeDrive;
VAR
   drive : Char;
   nbD : Byte;

BEGIN
     nbD := 0;
     FOR drive := 'A' TO 'F' DO
         IF testeDrive(drive) THEN
         BEGIN
              nbD := Succ(nbD);
              data[nbD] := drive + ':';
         END;
     IF nbD > 0 THEN
     BEGIN
          select := 1;
          data[1] := elargiADte(data[1],6);
          IF choix(xChoix,yChoix,6,nbD,select,data) THEN
             repert := compresse(data[select])
          ELSE
          BEGIN
               fin := True;
               select := 0;
          END;
     END;
END;


BEGIN
     sauvegarde(s);
     lastRep := '';
     repert := majuscule(repert);
     IF titre <> '' THEN
     BEGIN
          cacheCurseur;
          largeur := Length(titre) + 2;
          IF largeur < 24 THEN
             largeur := 24;
          IF posY + 14 <= absY THEN
             haut := posY
          ELSE
             haut := absY - 14;
          bas := haut + 14;
          IF posX + largeur <= absX THEN
             gauche := posX
          ELSE
             gauche := absX - largeur;
          droite := gauche + largeur + 1;
          centreRect(dlg.DRect,Length(titre)+2,5);
          WITH dlg DO
          BEGIN
               WITH DRect DO
               BEGIN
                    y1 := haut;
                    x1 := gauche;
                    y2 := bas;
                    x2 := droite;
               END;
               titre := '';
               DTyp := ombre2;
               clFond := coulDialogues;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulDialogues);
          coulTexte(coulTextes);
          Gotoxy(gauche+2,haut+1);
          Write(titre);
          xChoix := posX + (largeur DIV 2) - 9;
          yChoix := haut + 2;
     END
     ELSE
     BEGIN
          xChoix := posX;
          yChoix := posY;
     END;
     afficheRep := (fichier = '*.') AND (titre = '');
     fin := False;
     REPEAT
           IF litDir THEN
           BEGIN
                IF afficheRep THEN
                BEGIN
                     GotoXY(posX+2,posY-1);
                     Write(Copy(blanche,1,long+1));
                     IF Length(repert) > long THEN
                        long := Length(repert);
                     GotoXY(posX+2,posY-1);
                     IF repert[Length(repert)] = '\' THEN
                        Write(repert)
                     ELSE
                        Write(repert+'\');
                END;
                
                IF choix(xChoix,yChoix,10,nbFic,select,data) THEN
                BEGIN
                     IF data[select][1] = #16 THEN
                     BEGIN
                          IF repert[Length(repert)] = '\' THEN
                             repert := repert+compresse(Copy(data[select],2,
                                       Length(data[select])-1))
                          ELSE
                             repert := repert+'\'+compresse(Copy(data[select],
                                       2,Length(data[select])-1));
                     END
                     ELSE
                         IF data[select][1] = #17 THEN
                         BEGIN
                              il := Length(repert);
                              WHILE NOT (repert[il] IN ['\',':']) DO
                                    il := il - 1;
                              IF repert[il] <> ':' THEN
                                 lastRep := #16+' '+Copy(repert,il+1,
                                         Length(repert)-il);
                              il := Length(repert);
                              WHILE NOT (repert[il] IN ['\',':']) DO
                                    il := il - 1;
                              repert := Copy(repert,1,il);
                         END
                         ELSE
                         BEGIN
                              temp := compresse(data[select]);
                              IF temp[Length(temp)] <> ':' THEN
                              BEGIN
                                   fin := True;
                                   IF temp[1] <> '<' THEN
                                      fichier := temp
                                   ELSE
                                       fichier := ''
                              END
                              ELSE
                                  changeDrive;
                         END;
                END
                ELSE
                BEGIN
                     fin := True;
                     select := 0;
                END;
           END
           ELSE
               fin := True;
     UNTIL fin;
     choixFichier := select <> 0;
     fichier := majuscule(fichier);
     repert := majuscule(repert);
     IF select = 0 THEN
        fichier := '';
     IF repert[Length(repert)] <> '\' THEN
        repert := repert + '\';
     IF titre <> '' THEN
        fermeDialogue(dlg);
     restaure(s);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ D‚roule le rectangle de coordonn‚es 'x1,y1', 'x2,y2' de 'nbLn' vers le    }
{ bas ou le haut (suivant 'versBas').                                       }
{          (Le coin en haut … gauche de l'‚cran est rep‚r‚ 0,0)             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE derouleRect (nbLn, x1, y1, x2, y2 : Byte;  versBas : Boolean);
VAR
   attribut : Byte;

BEGIN
     attribut := TextAttr;
     Inline
     ($8A/$46/<nbLn     {       MOV AL,[BP+14]    ; nb lignes … d‚caler       }
     /$8A/$6E/<y1       {       MOV CH,[BP+12]    ; haut du rectangle         }
     /$8A/$4E/<x1       {       MOV CL,[BP+10]    ; gauche du rectangle       }
     /$8A/$76/<y2       {       MOV DH,[BP+8]     ; bas du rectangle          }
     /$8A/$56/<x2       {       MOV DL,[BP+6]     ; droite du rectangle       }
     /$8A/$7E/<attribut {       MOV BH,[BP-1]     ; remplissage des attributs }
     /$8A/$66/<versBas  {       MOV AH,[BP+4]     ; vers le bas ou le haut    }
     /$80/$C4/$06       {       ADD AH,6          ; AH = 6 ou 7               }
     /$CD/$10)          {       INT $10           ; Appel du BIOS             }
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Affiche l'‚cran point‚ par 'srcPtr' avec l'effet visuel 'effet'.     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE effetVisuel (scrPtr : Pointer;   effet : typEffet;
          vitesse : typVitesse);
VAR
   baseX, baseY, x, y, nbColsX, tempo : Byte;
   il, jl, kl, ll, temp, larg2 : Integer;

PROCEDURE scrollLeft;
INLINE
($1E               {       PUSH  DS                          }
/$A1/baseEcran     {       MOV   AX,baseEcran                }
/$8E/$C0           {       MOV   ES,AX                       }
/$8E/$D8           {       MOV   DS,AX                       }
/$B9/$D0/$07       {       MOV   CX,80*25                    }
/$FC               {       CLD                               }
/$BE/$02/$00       {       MOV   SI,2                        }
/$BF/$00/$00       {       MOV   DI,0                        }
/$F3/$A5           {       REP   MOVSW                       }
/$1F);             {       POP   DS                          }

PROCEDURE scrollRight;
INLINE
($1E               {       PUSH  DS                          }
/$A1/baseEcran     {       MOV   AX,baseEcran                }
/$8E/$C0           {       MOV   ES,AX                       }
/$8E/$D8           {       MOV   DS,AX                       }
/$B9/$D0/$07       {       MOV   CX,80*25                    }
/$FD               {       STD                               }
/$BE/$9E/$0F       {       MOV   SI,(160*25)-2               }
/$BF/$A0/$0F       {       MOV   DI,160*25                   }
/$F3/$A5           {       REP   MOVSW                       }
/$1F);             {       POP   DS                          }

BEGIN
     CASE vitesse OF
          rapide  : tempo := 0;
          moyenne : tempo := 10;
          lente   : tempo := 100;
     END;
     nbColsX := absX*2;
     larg2 := (absX - 1) * 2;
     CASE effet OF

        pousseAGauche :
        BEGIN
             FOR il := 0 TO absX-1 DO
             BEGIN
                  scrollLeft;
                  FOR jl := 0 TO absY-1 DO
                  BEGIN
                       temp := jl*nbColsX;
                       MemW[baseEcran:temp+nbColsX-2] :=
                       MemW[Seg(scrPtr^):Ofs(scrPtr^)+temp+(il*2)];
                  END;
                  Delay(tempo);
             END;
        END;

        pousseADroite :
        BEGIN
             FOR il := absX DOWNTO 0 DO
             BEGIN
                  scrollRight;
                  FOR jl := 0 TO absY-1 DO
                  BEGIN
                       temp := jl*nbColsX;
                       MemW[baseEcran:temp] :=
                       MemW[Seg(scrPtr^):Ofs(scrPtr^)+temp+(il*2)];
                  END;
                  Delay(tempo);
             END;
        END;

        pousseEnBas :
        BEGIN
             FOR il := absY-1 DOWNTO 0 DO
             BEGIN
                  derouleRect(1,0,0,absY-1,absX-1,True);
                  Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+(il*nbColsX)],
                       Mem[baseEcran:0],nbColsX);
                  Delay(tempo);
             END;
        END;

        pousseEnHaut :
        BEGIN
             kl := (absY-1)*nbColsX;
             FOR il := 0 TO absY-1 DO
             BEGIN
                  derouleRect(1,0,0,absY-1,absX-1,False);
                  Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+(il*nbColsX)],
                       Mem[baseEcran:kl],nbColsX);
                  Delay(tempo);
             END;
        END;

        ouvreVert :
        BEGIN
           kl := 0;
           ll := nbColsX-2;
           FOR jl := 1 TO absX DIV 2 DO
           BEGIN
              FOR il := 0 TO absY-1 DO
              BEGIN
                temp := nbColsX*il;
                Move(Mem[baseEcran:temp+2],Mem[baseEcran:temp],absX);
                MemW[baseEcran:temp+absX-2] := MemW[Seg(scrPtr^):Ofs(scrPtr^)
                                               +temp+kl];
                Move(Mem[baseEcran:temp+absX],Mem[baseEcran:temp+absX+2],absX);
                MemW[baseEcran:temp+absX] := MemW[Seg(scrPtr^):Ofs(scrPtr^)
                                             +temp+ll];
              END;
              kl := kl + 2;
              ll := ll - 2;
              Delay(tempo);
           END;
        END;

        fermeVert :
        BEGIN
           kl := absX-2;
           ll := absX;
           FOR jl := 1 TO absX DIV 2 DO
           BEGIN
              FOR il := 0 TO absY-1 DO
              BEGIN
                temp := nbColsX*il;
                Move(Mem[baseEcran:temp],Mem[baseEcran:temp+2],absX);
                MemW[baseEcran:temp] := MemW[Seg(scrPtr^):Ofs(scrPtr^)+temp
                                        +kl];
                Move(Mem[baseEcran:temp+absX+2],Mem[baseEcran:temp+absX],absX);
                MemW[baseEcran:temp+nbColsX-2] := MemW[Seg(scrPtr^):
                                                  Ofs(scrPtr^)+temp+ll];
              END;
              kl := kl - 2;
              ll := ll + 2;
              Delay(tempo);
           END;
        END;

        ouvreHoriz :
        BEGIN
           jl := ((absY DIV 2)-1)*nbColsX;
           kl := 0;
           ll := (absY-1) * nbColsX;
           FOR il := 1 TO absY DIV 2 DO
           BEGIN
             derouleRect(1,0,0,(absY DIV 2)-1,absX-1,False);
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+kl],Mem[baseEcran:jl],nbColsX);
             derouleRect(1,absY DIV 2,0,absY-1,absX-1,True);
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+ll],Mem[baseEcran:jl+nbColsX],
                  nbColsX);
             kl := kl + nbColsX;
             ll := ll - nbColsX;
             Delay(tempo);
           END;
           derouleRect(1,absY DIV 2,0,absY-1,absX-1,True);
           Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+ll],Mem[baseEcran:jl+nbColsX],
                nbColsX);
        END;

        fermeHoriz :
        BEGIN
           jl := (absY-1)*nbColsX;
           ll := (absY DIV 2)*nbColsX;
           kl := ((absY DIV 2)-1) * nbColsX;
           derouleRect(1,absY DIV 2,0,absY-1,absX-1,False);
           Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+ll],Mem[baseEcran:jl],nbColsX);
           ll := ll + nbColsX;
           FOR il := 1 TO absY DIV 2 DO
           BEGIN
             derouleRect(1,0,0,(absY DIV 2)-1,absX-1,True);
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+kl],Mem[baseEcran:0],nbColsX);
             derouleRect(1,absY DIV 2,0,absY-1,absX-1,False);
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+ll],Mem[baseEcran:jl],nbColsX);
             kl := kl - nbColsX;
             ll := ll + nbColsX;
             Delay(tempo);
           END;
        END;

        ouvreZoom :
        BEGIN
          baseX := 40;
          baseY := 13;
          x := baseX;
          y := baseY;
          jl := 1;
          kl := 1;
          FOR il := 1 TO 12 DO
          BEGIN
             temp := x;
             x := baseX + (jl*3);
             FOR ll := temp TO x DO
             BEGIN
                larg2 := ((y-1)*nbColsX)+((ll-1)*2);
                Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],
                     6);
             END;

             temp := y;
             y := baseY + kl;
             FOR ll := temp TO y DO
             BEGIN
                larg2 := ((ll-1)*nbColsX)+((x-1)*2);
                Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],
                     6);
             END;

             temp := x;
             x := baseX - (jl*3);
             FOR ll := temp DOWNTO x DO
             BEGIN
                larg2 := ((y-1)*nbColsX)+((ll-1)*2);
                Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],
                     6);
             END;

             temp := y;
             y := baseY - kl;
             FOR ll := temp DOWNTO y DO
             BEGIN
                larg2 := ((ll-1)*nbColsX)+((x-1)*2);
                Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],
                     6);
             END;
             jl := jl + 1;
             kl := kl + 1;
             Delay(tempo);
          END;
          temp := x;
          x := baseX + (jl*3);
          FOR ll := temp TO x DO
          BEGIN
             larg2 := ((y-1)*nbColsX)+((ll-1)*2);
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],6);
          END;
          temp := y;
          y := baseY + kl;
          FOR ll := temp TO y DO
          BEGIN
             larg2 := ((ll-1)*nbColsX)+((x-1)*2);
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],4);
          END;
          x := 1;
          temp := y;
          FOR ll := temp DOWNTO 1 DO
          BEGIN
             larg2 := ((ll-1)*nbColsX)+((x-1)*2);
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],6);
          END;
        END;

        fermeZoom :
        BEGIN
           baseX := 40;
           baseY := 13;
           FOR ll := 1 TO absY DO
           BEGIN
             larg2 := (ll-1)*nbColsX;
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],6);
           END;
           FOR ll := absY DOWNTO 1 DO
           BEGIN
             larg2 := ((ll-1)*nbColsX)+((absX-2)*2);
             Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],4);
           END;
           x := 4;
           y := 2;
           jl := 12;
           kl := 12;
           FOR il := 1 TO 13 DO
           BEGIN
             temp := y;
             y := baseY + kl;
             FOR ll := temp TO y DO
             BEGIN
                larg2 := ((ll-1)*nbColsX)+((x-1)*2);
                Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],
                     6);
             END;
             temp := x;
             x := baseX + (jl*3);
             FOR ll := temp TO x DO
             BEGIN
                larg2 := ((y-1)*nbColsX)+((ll-1)*2);
                Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],
                     6);
             END;
             temp := y;
             y := baseY - kl;
             FOR ll := temp DOWNTO y DO
             BEGIN
                larg2 := ((ll-1)*nbColsX)+((x-1)*2);
                Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],
                     6);
             END;
             temp := x;
             x := baseX - (jl*3);
             FOR ll := temp DOWNTO x DO
             BEGIN
                larg2 := ((y-1)*nbColsX)+((ll-1)*2);
                Move(Mem[Seg(scrPtr^):Ofs(scrPtr^)+larg2],Mem[baseEcran:larg2],
                     6);
             END;
             jl := jl - 1;
             kl := kl - 1;
             Delay(tempo);
           END;
        END;
     END;
END;

END.