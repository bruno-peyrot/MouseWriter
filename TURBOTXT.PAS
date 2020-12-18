UNIT TurboTxt;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                                                                           }
{                                TurboTXT                                   }
{                                                                           }
{     - Menus d‚roulants hi‚rarchis‚s en mode texte pour Turbo Pascal -     }
{                                                                           }
{                par Jean-Edouard & Thomas LACHAND-ROBERT                   }
{                                                                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

INTERFACE

USES
    Dos,
    Crt,
    TurboLib;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
CONST
     maxPeres = 20;          { 10 menus et 10 sous-menus }
     maxFils  = 22;          { nombre maxi de fils par pŠre de menu }


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
TYPE
    posTxt = RECORD         { un point d'affichage sur l'‚cran }
                   x, y : Byte;
             END;

    rectTxt = RECORD        { un rectangle d‚fini par deux points }
              CASE Byte OF
                   1 : (hautGauche, basDroit : posTxt);
                   2 : (x1, y1 ,x2, y2 : Byte);
              END;

    filsPtr = ^filsRec;     { d‚finition d'un fils de menu }
    filsRec = RECORD
                      select : Boolean;      { vrai si le fils est activ‚ }
                      marque : Boolean;      { vrai si le fils est marqu‚ }
                      texte  : String[30];   { texte du fils de menu }
                      touche : Char;         { touche directe ‚quivalente }
                END;

    barrePtr  = ^barreMenu;  { d‚finition d'une barre de menus }
    barreMenu =
    RECORD
          nbMenus :   Byte;      { nb de menus }
          nbSMenus :  Byte;      { nb de sous-menus }
          clBarre :   couleur;   { couleur de la barre des menus }
          clPeres :   couleur;   { couleur des pŠres }
          clFils :    couleur;   { couleur des fils }
          clFond :    couleur;   { couleur de fond des fils }
          menus : ARRAY [1..maxPeres] OF
             RECORD
                   titre     : String[20];  { titre du menu }
                   mPere     : Byte;        { nø du menu pŠre (sous-menu) }
                   optPere   : Byte;        { nø de l'option pŠre (sous-menu) }
                   posX      : Byte;        { position sur la barre des menus }
                   nbFils    : Byte;        { nombre de fils pour ce menu }
                   lFils      : ARRAY [1..maxFils] OF filsPtr;
                   dernier   : Byte;        { derniŠr fils s‚lectionn‚ }
                   rectOpts  : rectTxt;     { rectangle du menu d‚roul‚ }
                   taille    : Word;        { taille des donn‚es recouvertes }
                   donnees   : Pointer;     { donn‚es recouvertes par le menu }
             END;
          carOptions : Set of Char;  { ensemble des touches directes }
    END;


    action = (sansAction, clavier, choixMenu);   { actions possibles }

    typAction = RECORD
                      actType   : action;  { type d'action enregistr‚e }
                      actTouche : Char;    { touche pour une action clavier }
                      actPere   : Byte;    { pŠre pour une action menu }
                      actFils : Byte;      { fils pour une action menu }
                END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
VAR
   bMenu   : barrePtr;        { pointeur sur la barre de menus courante }
   ouvert  : Byte;            { num‚ro du menu courament ouvert }
   dernierMenu : Byte;        { num‚ro du dernier menu ouvert }
   etatClv : Byte;            { ‚tat des touches sp‚ciales du clavier }
   lAction : typAction;       { variable de stockage des actions }


PROCEDURE ajouteMenu (tMenu : str80);
PROCEDURE ajouteOption (pere : Byte;   fils : Str80;   touche : Char);
PROCEDURE dessineBarreMenu;
PROCEDURE metTexteFils (pere, fils : Byte;  texte : str80);
PROCEDURE selectFils (pere, fils : Byte);
PROCEDURE deSelectFils (pere, fils : Byte);
FUNCTION  litEtatFils (pere, fils : Byte) : Boolean;
PROCEDURE marqueFils (pere, fils : Byte);
PROCEDURE demarqueFils (pere, fils : Byte);
PROCEDURE ouvreMenu (pere, fils : Byte);
FUNCTION  actionMenu (VAR action : typAction) : Boolean;


IMPLEMENTATION


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{               Inverse le menu 'pere' sur la barre des menus.                }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ecritMenu (pere : Byte);
VAR
   s : typSauv;

BEGIN
     IF pere IN [1..bMenu^.nbMenus] THEN
     BEGIN
          sauvegarde(s);
          WITH bMenu^.menus[pere] DO
          BEGIN
               IF machine.modeCouleur THEN
               BEGIN
                    IF pere = ouvert THEN
                       coulFond(bMenu^.clFond)
                    ELSE
                        coulFond(noir);
                    coulTexte(bMenu^.clPeres);
                    Gotoxy(posX-1,1);
                    Write(' ',titre,' ');
               END
               ELSE
                   IF pere = ouvert THEN
                      inverseTexte(posX-1,1,Length(titre)+2)
                   ELSE
                   BEGIN
                        Gotoxy(posX-1,1);
                        Write(' ',titre,' ');
                   END;
          END;
          restaure(s);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                Ferme le menu 'pere' sur la barre des menus.                 }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE fermeMenu (pere : Byte);
BEGIN
     IF pere <> 0 THEN
        WITH bMenu^.menus[pere] DO
          IF (nbFils > 0) AND (donnees <> NIL) THEN
          BEGIN
               WITH rectOpts DO
                    litRectTexte(x1,y1,x2,y2,donnees);
               FreeMem(donnees,taille);
               donnees := NIL;
               IF pere = ouvert THEN
                  ouvert := 0;
               ecritMenu(pere);
          END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        Ajoute le menu de titre 'tMenu' … la barre de menus courante.        }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ajouteMenu (tMenu : str80);
VAR
   pere, fils : Byte;

BEGIN
     fermeMenu(ouvert);
     IF bMenu = NIL THEN
     BEGIN
          New(bMenu);
          FillChar(bMenu^,SizeOf(bMenu^),#0);
          WITH bMenu^ DO
          BEGIN
               menus[1].posX := 3;
               clBarre := blanc;
               clPeres := blanc;
               clFils  := blanc;
               clFond  := noir;
          END;
          dernierMenu := 0;
     END;
     IF bMenu^.nbMenus + bMenu^.nbSMenus < maxPeres THEN
        IF (Length(tMenu) = 4) AND (tMenu[1] IN ['0'..'9']) THEN {sous-Menu?}
        BEGIN
             pere := strToInt(Copy(tMenu,1,2));
             IF (pere IN [1..bMenu^.nbMenus]) THEN
             WITH bMenu^ DO
             BEGIN
                fils := strToInt(Copy(tMenu,3,2));
                IF fils IN [1..menus[pere].nbFils] THEN
                  IF menus[pere].lFils[fils]^.texte <> '-' THEN
                  BEGIN
                     nbSMenus := Succ(nbSMenus);
                     WITH menus[nbMenus+nbSMenus] DO
                     BEGIN
                          optPere := fils;
                          mPere := pere;
                          nbFils := 0;
                          titre := tMenu;
                          posX := menus[mPere].rectOpts.x2 + 1;
                     END;
                     menus[pere].lFils[fils]^.touche := Chr(nbMenus+nbSmenus);
                  END;
             END;
        END
        ELSE
          IF bMenu^.nbMenus < 10 THEN
          BEGIN
             bMenu^.nbMenus := Succ(bMenu^.nbMenus);
             IF bMenu^.nbSMenus > 0 THEN
                WITH bMenu^ DO
                BEGIN
                   menus[nbMenus+nbSMenus] := menus[nbMenus];
                   menus[menus[nbMenus].mPere].lFils[menus[nbMenus].optPere]^.
                      touche := Chr(nbMenus+nbSmenus);
                   FillChar(menus[nbMenus],SizeOf(menus[nbMenus]),#0);
                   IF nbMenus > 1 THEN
                      menus[nbMenus].posX := menus[nbMenus-1].posX + 2 +
                         Length(menus[nbMenus-1].titre)
                   ELSE
                      menus[nbMenus].posX := 3;
                END;
             WITH bMenu^.menus[bMenu^.nbMenus] DO
             BEGIN
                  nbFils := 0;
                  titre := tMenu;
                  IF bMenu^.nbMenus < maxPeres THEN
                     bMenu^.menus[bMenu^.nbMenus+1].posX := posX + 2 +
                       Length(titre);
             END;
          END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                    Calcule le rectangle du menu 'pere'.                     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE calcTailleMenu (pere : Byte);
VAR
   larg, largMenu, jl : Byte;

BEGIN
     IF bMenu <> NIL THEN
        IF pere <= bMenu^.nbMenus + bMenu^.nbSMenus THEN
           WITH bMenu^.menus[pere] DO
           BEGIN
                largMenu := 0;
                IF nbFils > 0 THEN
                   FOR jl := 1 TO nbFils DO
                   BEGIN
                        larg := Length(lFils[jl]^.texte) + 2;
                        IF lFils[jl]^.touche IN ['A'..'Z'] THEN
                           larg := larg + 4
                        ELSE
                            IF lFils[jl]^.touche <> carNul THEN
                               larg := larg + 2;
                        IF larg > largMenu THEN
                           largMenu := larg;
                   END;
                jl := posX - 2;
                WHILE jl + largMenu + 1 >= absX DO
                      jl := jl - 1;
                WITH rectOpts DO
                BEGIN
                     x1 := jl;
                     x2 := jl + largMenu + 1;
                     IF mPere = 0 THEN
                        y1 := 2
                     ELSE
                     BEGIN
                          jl := Ord(optPere) - 1;
                          WHILE jl + nbFils + 2 >= absY DO
                                jl := jl - 1;
                          y1 := jl + 2;
                     END;
                     y2 := y1 + nbFils + 1;
                     taille := (x2 - x1 + 1) * (y2 - y1 + 1) * 2;
                END;
           END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Ajoute le fils de texte 'fils' et de touche 'touche' au menu 'pere'.     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ajouteOption (pere : Byte;   fils : Str80;   touche : Char);
VAR
   jl, larg, largMenu : Integer;

BEGIN
     IF bMenu <> NIL THEN
     BEGIN
          IF pere > 10 THEN
             pere := bMenu^.nbMenus+(pere - 10);
          IF pere <= bMenu^.nbMenus + bMenu^.nbSMenus THEN
          WITH bMenu^.menus[pere] DO
          BEGIN
               fermeMenu(ouvert);
               IF nbFils < maxFils THEN
               BEGIN
                    nbFils := Succ(nbFils);
                    New(lFils[nbFils]);
                    FillChar(lFils[nbFils]^,SizeOf(filsRec),#0);
                    lFils[nbFils]^.texte := fils;
                    IF fils <> '-' THEN
                    BEGIN
                         IF touche IN ['a'..'z'] THEN
                            touche := Chr(Ord(touche) - $20);
                         IF touche IN ['A'..'Z'] THEN
                            lFils[nbFils]^.touche := touche;
                    END;
                    calcTailleMenu(pere);
               END;
          END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                        Dessine la barre des menus.                        }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE dessineBarreMenu;
VAR
   xPos, il : Byte;
   s : typSauv;

BEGIN
     IF bMenu <> NIL THEN
     BEGIN
          fermeMenu(ouvert);
          sauvegarde(s);
          xPos := 3;
          coulFond(noir);
          coulTexte(bMenu^.clBarre);
          Gotoxy(1,2);
          Write(ligne1);
          coulTexte(bMenu^.clPeres);
          IF bMenu^.nbMenus > 0 THEN
             FOR il := 1 TO bMenu^.nbMenus DO
             BEGIN
                  Gotoxy(xPos,1);
                  Write(bMenu^.menus[il].titre);
                  xPos := xPos + Length(bMenu^.menus[il].titre) + 2;
             END;
          restaure(s);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{       Le fils 'fils' du pŠre 'pere' est affect‚ du texte 'texte'.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE metTexteFils (pere, fils : Byte;  texte : str80);
BEGIN
     IF bMenu <> NIL THEN
     BEGIN
          IF pere > 10 THEN
             pere := bMenu^.nbMenus+(pere - 10);
          IF pere <= bMenu^.nbMenus + bMenu^.nbSMenus THEN
          WITH bMenu^.menus[pere] DO
               IF fils IN [1..nbFils] THEN
               BEGIN
                    lFils[fils]^.texte := texte;
                    calcTailleMenu(pere);
               END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{        Dessine le fils 'fils' du pŠre 'pere' dans son ‚tat courant.       }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE dessineFils (pere, fils : Byte);
VAR
   larg : Byte;

BEGIN
     IF bMenu <> NIL THEN
        WITH bMenu^.menus[pere] DO
        BEGIN
             coulTexte(bMenu^.clFils);
             coulFond(bMenu^.clFond);
             highVideo;
             larg := rectOpts.x2 - rectOpts.x1 - 1;
             Gotoxy(rectOpts.x1+1,rectOpts.y1+fils);
             Write(COPY(blanche,1,larg));
             IF NOT lFils[fils]^.select THEN
                lowVideo;
             IF lFils[fils]^.texte = '-' THEN
             BEGIN
                  Gotoxy(rectOpts.x1+1,rectOpts.y1+fils);
                  Write(Copy(ligne1,1,larg));
             END
             ELSE
             BEGIN
                  IF lFils[fils]^.marque THEN
                  BEGIN
                       Gotoxy(rectOpts.x1+1,rectOpts.y1+fils);
                       Write(#16,lFils[fils]^.texte);
                  END
                  ELSE
                  BEGIN
                       Gotoxy(rectOpts.x1+2,rectOpts.y1+fils);
                       Write(lFils[fils]^.texte);
                  END;
                  IF lFils[fils]^.touche IN ['A'..'Z'] THEN
                  BEGIN
                       Gotoxy(rectOpts.x2-4,rectOpts.y1+fils);
                       Write('[',lFils[fils]^.touche,']');
                  END
                  ELSE
                      IF lFils[fils]^.touche <> carNul THEN
                      BEGIN
                           Gotoxy(rectOpts.x2-2, fils+2);
                           Write(#16);
                      END;
             END;
             highVideo;
        END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{             Rend le fils 'fils' du pŠre 'pere' s‚lectionnable.            }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE selectFils (pere, fils : Byte);
VAR
   s : typSauv;

BEGIN
     IF bMenu <> NIL THEN
     BEGIN
        IF pere > 10 THEN
           pere := bMenu^.nbMenus+(pere - 10);
        IF pere <= bMenu^.nbMenus + bMenu^.nbSMenus THEN
        WITH bMenu^, bMenu^.menus[pere] DO
           IF fils IN [1..nbFils] THEN
              IF lFils[fils]^.texte <> '-' THEN
              BEGIN
                 lFils[fils]^.select := TRUE;
                 IF (lFils[fils]^.touche <> carNul) AND
                  (Ord(lFils[fils]^.touche) >= $40) AND (carOptions <> []) THEN
                  carOptions := carOptions+[Chr(Ord(lFils[fils]^.touche)-$40)];
                 IF (ouvert = pere) AND (donnees <> NIL) THEN
                 BEGIN
                      sauvegarde(s);
                      dessineFils(pere,fils);
                      restaure(s);
                 END;
              END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{           Rend le fils 'fils' du pŠre 'pere' non s‚lectionnable.          }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE deSelectFils (pere, fils : Byte);
VAR
   s : typSauv;

BEGIN
     IF bMenu <> NIL THEN
     BEGIN
        IF pere > 10 THEN
           pere := bMenu^.nbMenus+(pere - 10);
        IF pere <= bMenu^.nbMenus + bMenu^.nbSMenus THEN
        WITH bMenu^, bMenu^.menus[pere] DO
           IF fils IN [1..nbFils] THEN
           BEGIN
                lFils[fils]^.select := FALSE;
                IF (lFils[fils]^.touche <> carNul) AND
                  (Ord(lFils[fils]^.touche) >= $40) AND (carOptions <> []) THEN
                  carOptions := carOptions-[Chr(Ord(lFils[fils]^.touche)-$40)];
                IF (ouvert = pere) AND (donnees <> NIL) THEN
                BEGIN
                     sauvegarde(s);
                     dessineFils(pere,fils);
                     restaure(s);
                END;
             END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{       Renvoie l'‚tat courant (s‚lectionnable ou non) du fils 'fils'.      }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION litEtatFils (pere, fils : Byte) : Boolean;
BEGIN
     litEtatFils := False;
     IF bMenu <> NIL THEN
     BEGIN
          IF pere > 10 THEN
             pere := bMenu^.nbMenus+(pere - 10);
          IF pere <= bMenu^.nbMenus + bMenu^.nbSMenus THEN
          WITH bMenu^, bMenu^.menus[pere] DO
               IF fils IN [1..nbFils] THEN
                  litEtatFils := lFils[fils]^.select;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                  Marque le fils 'fils' du pŠre 'pere'.                    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE marqueFils (pere, fils : Byte);
BEGIN
     IF bMenu <> NIL THEN
     BEGIN
          IF pere > 10 THEN
             pere := bMenu^.nbMenus+(pere - 10);
          IF pere <= bMenu^.nbMenus + bMenu^.nbSMenus THEN
          WITH bMenu^, bMenu^.menus[pere] DO
               IF fils IN [1..nbFils] THEN
                  lFils[fils]^.marque := lFils[fils]^.texte <> '-';
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{             Retire la marque du fils 'fils' du pŠre 'pere'.               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE demarqueFils (pere, fils : Byte);
BEGIN
     IF bMenu <> NIL THEN
     BEGIN
          IF pere > 10 THEN
             pere := bMenu^.nbMenus+(pere - 10);
          IF pere <= bMenu^.nbMenus + bMenu^.nbSMenus THEN
          WITH bMenu^, bMenu^.menus[pere] DO
               IF fils IN [1..nbFils] THEN
                  lFils[fils]^.marque := False;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{     Inverse le fils 'fils' du pŠre 'pere' dans sa boite de s‚lection.     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE inverseFils (pere, fils : Byte);
VAR
   larg : Byte;

BEGIN
     WITH bMenu^.menus[pere] DO
     BEGIN
          larg := rectOpts.x2 - rectOpts.x1 - 1;
          inverseTexte(rectOpts.x1+1,rectOpts.y1+fils,larg);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{             Trouve le premier fils s‚lectionnable du menu 'pere'.           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION premSelect (pere : Byte) : Byte;
VAR
   il : Byte;

BEGIN
     il := 1;
     WITH bMenu^.menus[pere] DO
     BEGIN
          WHILE (il <= nbFils) AND NOT lFils[il]^.select DO
                il := Succ(il);
          IF il > nbFils THEN
             premSelect := 0
          ELSE
              premSelect := il;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{      Dessine la boite de s‚lection du pŠre 'pere' avec tous ses fils.     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE dessineRectFils (pere : Byte);
VAR
   il, larg, fils : Byte;
   s : typSauv;

BEGIN
     WITH bMenu^.menus[pere] DO
        IF nbFils > 0 THEN
        BEGIN
           IF mPere <> 0 THEN
              IF bMenu^.menus[mPere].donnees = NIL THEN
              BEGIN
                 dessineRectFils(mPere);
                 IF bMenu^.menus[mPere].dernier = 0 THEN
                    fils := premSelect(mPere)
                 ELSE
                    IF bMenu^.menus[mPere].lFils[bMenu^.menus[mPere].dernier]^.
                       select THEN
                       fils := bMenu^.menus[mPere].dernier
                    ELSE
                       fils := premSelect(mPere);
                 IF fils > 0 THEN
                    inverseFils (mPere,fils);
              END;
           sauvegarde(s);
           coulFond(noir);
           coulTexte(bMenu^.clBarre);
           GetMem(donnees,taille);
           WITH rectOpts DO
           BEGIN
                sauveRectTexte(x1,y1,x2,y2,donnees);
                rectTexte(x1,y1,x2,y2,2,TRUE);
           END;
           larg := rectOpts.x2 - rectOpts.x1 - 1;
           FOR il := 1 TO nbFils DO
               dessineFils(pere,il);
           restaure(s);
           ouvert := pere;
           ecritMenu(pere);
        END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{  Teste si la touche 'touche' appelle un menu ou une fils. Si c'est le cas,  }
{  le fils et le menu sont renvoy‚s dans 'cPere' et 'cFils'.                  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION toucheMenu (touche : Char;   VAR cPere, cFils : Byte) : Boolean;
VAR
   leMenu, lOption : Byte;
   fin : Boolean;

BEGIN
     toucheMenu := FALSE;
     WITH bMenu^ DO
          IF etatClv AND ctrlMsk <> 0 THEN
          BEGIN
             fin := FALSE;
             cPere := 0;
             cFils := 0;
             leMenu := 0;
             REPEAT
                 leMenu := Succ(leMenu);
                 WITH menus[leMenu] DO
                 BEGIN
                    lOption := 0;
                    IF Ord(titre[1]) - $40 = Ord(touche) THEN
                       fin := TRUE
                    ELSE
                    REPEAT
                        lOption := Succ(lOption);
                        IF lFils[lOption]^.select THEN
                          fin := Ord(lFils[lOption]^.touche)-$40 = Ord(touche);
                    UNTIL fin OR (lOption = nbFils);
                 END;
             UNTIL fin OR (leMenu = nbMenus + nbSMenus);
             IF fin THEN
             BEGIN
                  toucheMenu := TRUE;
                  cPere := leMenu;
                  cFils := lOption;
                  IF cFils = 0 THEN
                     cFils := 255;
             END;
          END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{   GŠre toutes les actions dans une boite. Renvoie 0 ou le fils choisi.    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE menuAction (VAR pere, fils : Byte);
VAR
   nouvOpt, il : Integer;
   etatCurseur : Boolean;
   cPere, cFils : Byte;
   car : Char;

PROCEDURE petitBip;
BEGIN
     IF faitBip THEN
     BEGIN
          Sound(200);
          Delay(50);
          NoSound;
     END;
END;

PROCEDURE changeMenu;
VAR
   deroule : Boolean;
   mOuvert : Byte;

BEGIN
     deroule := True;
     IF ouvert <> 0 THEN
     BEGIN
          mOuvert := ouvert;
          IF bMenu^.menus[mOuvert].mPere <> 0 THEN
          BEGIN
               fermeMenu(ouvert);
               IF bMenu^.menus[mOuvert].mPere <> pere THEN
                  fermeMenu(bMenu^.menus[mOuvert].mPere)
               ELSE
               BEGIN
                    ouvert := bMenu^.menus[mOuvert].mPere;
                    deroule := False;
               END;
          END
          ELSE
              IF bMenu^.menus[pere].mPere <> mOuvert THEN
                 fermeMenu(ouvert);
     END;
     IF deroule THEN
     BEGIN
          dessineRectFils(pere);
          petitBip;
     END;
     IF bMenu^.menus[pere].dernier = 0 THEN
        fils := premSelect(pere)
     ELSE
         IF bMenu^.menus[pere].lFils[bMenu^.menus[pere].dernier]^.select THEN
            fils := bMenu^.menus[pere].dernier
         ELSE
             fils := premSelect(pere);
     IF deroule AND (fils > 0) THEN
        inverseFils(pere,fils);
END;

FUNCTION trouvePrec (Pos : Byte) : Byte;
BEGIN
     il := Pos;
     WITH bMenu^.menus[pere] DO
          REPEAT
                IF il > 1 THEN
                   il := il - 1
                ELSE
                   il := nbFils;
          UNTIL lFils[il]^.select OR (il = Pos);
    trouvePrec := il
END;

FUNCTION trouveSuiv (Pos : Byte) : Byte;
BEGIN
     il := Pos;
     WITH bMenu^.menus[pere] DO
          REPEAT
                il := 1 + (il MOD nbFils);
          UNTIL lFils[il]^.select OR (il = Pos);
     trouveSuiv := il;
END;

BEGIN
     IF bMenu <> NIL THEN
     BEGIN
        IF pere = 0 THEN
           pere := 1;
        etatCurseur := curseurVis;
        cacheCurseur;
        IF ouvert = 0 THEN
           changeMenu
        ELSE
        BEGIN
             IF bMenu^.menus[pere].dernier = 0 THEN
                fils := premSelect(pere)
             ELSE
                 IF bMenu^.menus[pere].lFils[bMenu^.menus[pere].dernier]^.
                      select THEN
                    fils := bMenu^.menus[pere].dernier
                 ELSE
                     fils := premSelect(pere);
             IF fils > 0 THEN
                inverseFils(pere,fils);
        END;
        REPEAT
            appelTache;
            IF KeyPressed THEN
            BEGIN
               car := ReadKey;
               etatClv := etatClavier;
               IF (car = carRet) AND (fils = 0) THEN
                  car := #255;
               IF (car = carNul) AND KeyPressed THEN
               BEGIN
                  car := ReadKey;
                  CASE car OF
                     flchBas    :
                     IF fils > 0 THEN
                     BEGIN
                          nouvOpt := trouveSuiv(fils);
                          IF nouvOpt <> fils THEN
                          BEGIN
                               inverseFils(pere,fils);
                               petitBip;
                               fils := nouvOpt;
                               inverseFils(pere,fils);
                          END;
                     END;

                     flchHaut   :
                     IF fils > 0 THEN
                     BEGIN
                          nouvOpt := trouvePrec(fils);
                          IF nouvOpt <> fils THEN
                          BEGIN
                               inverseFils(pere,fils);
                               petitBip;
                               fils := nouvOpt;
                               inverseFils(pere,fils);
                          END;
                      END;

                      flchDroite :
                      BEGIN
                           bMenu^.menus[pere].dernier := fils;
                           IF bMenu^.menus[pere].mPere = 0 THEN
                              pere := 1 + (pere MOD bMenu^.nbMenus)
                           ELSE
                              pere := bMenu^.menus[pere].mPere;
                           changeMenu;
                      END;

                      flchGauche :
                      BEGIN
                           bMenu^.menus[pere].dernier := fils;
                           IF bMenu^.menus[pere].mPere = 0 THEN
                           BEGIN
                                IF pere > 1 THEN
                                   pere := pere - 1
                                ELSE
                                   pere := bMenu^.nbMenus;
                           END
                           ELSE
                               pere := bMenu^.menus[pere].mPere;
                           changeMenu;
                       END;
                  END;
               END
               ELSE
               BEGIN
                    IF toucheMenu(car,cPere,cFils) THEN
                    BEGIN
                         il := pere;
                         bMenu^.menus[pere].dernier := fils;
                         pere := cPere;
                         IF cFils <> 255 THEN
                         BEGIN
                              IF bMenu^.menus[il].mPere = pere THEN
                              BEGIN
                                 fermeMenu(ouvert);
                                 ouvert := cPere;
                                 IF bMenu^.menus[pere].dernier > 0 THEN
                                  inverseFils(pere,bMenu^.menus[pere].dernier);
                              END;
                              bMenu^.menus[pere].dernier := cFils;
                              changeMenu;
                              car := carRet;
                         END
                         ELSE
                             changeMenu;
                    END
                    ELSE
                        IF car = carRet THEN
                        BEGIN
                             car := bMenu^.menus[pere].lFils[fils]^.touche;
                             IF car IN [carNul,'A'..'Z'] THEN
                                car := carRet
                             ELSE
                             BEGIN
                                  bMenu^.menus[pere].dernier := fils;
                                  pere := Ord(car);
                                  changeMenu;
                             END;
                        END
                        ELSE
                            IF car = carEsc THEN
                            BEGIN
                                 IF bMenu^.menus[pere].mPere <> 0 THEN
                                 BEGIN
                                      bMenu^.menus[pere].dernier := fils;
                                      car := #255;
                                      pere := bMenu^.menus[pere].mPere;
                                      changeMenu;
                                 END;
                            END;
               END;
            END;
        UNTIL car IN [carEsc,carRet];
        bMenu^.menus[pere].dernier := fils;
        IF car = carEsc THEN
           fils := 0;
        IF fils > 0 THEN
        BEGIN
             unBip;
             FOR il := 1 TO 6 DO
             BEGIN
                  inverseFils(pere,fils);
                  Delay(60);
             END;
        END;
        IF fils = 0 THEN
           pere := 0;
        IF bMenu^.menus[ouvert].mPere <> 0 THEN
        BEGIN
             il := ouvert;
             fermeMenu(ouvert);
             fermeMenu(bMenu^.menus[il].mPere);
             IF pere <> 0 THEN
                pere := (pere - bMenu^.nbMenus) + 10;
        END
        ELSE
            fermeMenu(ouvert);
        dernierMenu := pere;
        IF etatCurseur THEN
           montreCurseur;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{   Inverse le menu 'pere' sur la barre des menus pendant une 1/4 seconde.    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE montreMenu (pere : Byte);
VAR
   oldOuvert : Byte;

BEGIN
     oldOuvert := ouvert;
     ouvert := pere;
     ecritMenu(pere);
     Delay(250);
     ouvert := 0;
     ecritMenu(pere);
     ouvert := oldOuvert;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{            Force l'ouverture du menu 'pere' sur le fils 'fils'.             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ouvreMenu (pere, fils : Byte);
BEGIN
     IF (bMenu <> NIL) AND (ouvert = 0) THEN
     WITH bMenu^ DO
     BEGIN
        IF menus[pere].mPere <> 0 THEN
        IF NOT menus[menus[pere].mPere].lFils[menus[pere].optPere]^.select THEN
           pere := menus[pere].mPere;
        WITH menus[pere] DO
        BEGIN
             IF fils IN [1..nbFils] THEN
                dernier := fils
             ELSE
                 dernier := 0;
             dessineRectFils(pere);
        END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Attente d'un ‚v‚nement utilisateur. Vrai si c'est un ‚v‚nement menu.     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION actionMenu (VAR action : typAction) : Boolean;
BEGIN
     appelTache;
     actionMenu := FALSE;
     IF ouvert <> 0 THEN
     BEGIN
          WITH action DO
          BEGIN
               actPere := ouvert;
               menuAction(actPere,actFils);
               IF actPere <> 0 THEN
               BEGIN
                    actType := choixMenu;
                    actionMenu := TRUE;
               END;
          END;
     END
     ELSE
         IF KeyPressed THEN
         BEGIN
              etatClv := etatClavier;
              WITH action DO
              BEGIN
                   actTouche := ReadKey;
                   IF (actTouche = carNul) AND Keypressed THEN
                        actTouche := ReadKey;
                   IF toucheMenu(actTouche,actPere,actFils) THEN
                   BEGIN
                        IF actFils = 255 THEN
                           menuAction(actPere,actFils)
                        ELSE
                           montreMenu(actPere);
                        IF actPere <> 0 THEN
                        BEGIN
                             actType := choixMenu;
                             actionMenu := TRUE;
                        END;
                   END
                   ELSE
                   BEGIN
                        actType := clavier;
                        actionMenu := TRUE;
                   END;
              END;
         END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Pr‚-initialisation de TurboTxt }
BEGIN
     bMenu := NIL;          { Pas de menus }
     ouvert := 0;           { aucun menu n'est ouvert }
END.