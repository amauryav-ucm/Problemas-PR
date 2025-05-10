from z3 import *
import json
import sys

import sys
import io

filenameIn = sys.argv[1]
data = json.load(open(filenameIn, "r"))
if len(sys.argv) > 2:
    filenameOut = sys.argv[2]
    sys.stdout = open(filenameOut, mode="w")

# FUNCIONES AUXILIARES


def ncomprado(mes, aceite):
    return "comprado_" + str(mes) + "_" + str(aceite)


def nrefinado(mes, aceite):
    return "refinado_" + str(mes) + "_" + str(aceite)


def nalmacen(mes, aceite):
    return "almacen_" + str(mes) + "_" + str(aceite)


def addSumMat(mat):
    acc = 0
    for row in mat:
        for val in row:
            acc += val
    return acc


def addSumMatRange(mat, iRow, fRow, iCol, fCol):
    acc = 0
    for row in range(iRow, fRow):
        for col in range(iCol, fCol):
            acc += mat[row][col]
    return acc


def addInnerProd(mat1, mat2):
    acc = 0
    for row in range(len(mat1)):
        acc += addDotProd(mat1[row], mat2[row])
    return acc


def addDotProd(vec1, vec2):
    acc = 0
    for i in range(len(vec1)):
        acc += vec1[i] * vec2[i]
    return acc


def addSum(vec):
    acc = 0
    for i in range(len(vec)):
        acc += vec[i]
    return acc


# DATOS DE ENTRADA

nA = 5
nM = 6

valor = data["VALOR"]
dureza = data["dureza"]
precios = data["precios"]
maxV = data["MAXV"]
maxN = data["MAXN"]
mCap = data["MCAP"]
cA = data["CA"]
minD = data["MinD"]
maxD = data["MaxD"]
minB = data["MinB"]
inicial = data["inicial"]
pV = data["PV"]

# VARIABLES

s = Optimize()

beneficio = Int("beneficio")
comprado = []
refinado = []
almacen = []

for mes in range(nM):
    auxComprado = []
    auxRefinado = []
    for aceite in range(nA):
        auxComprado.append(Int(ncomprado(mes, aceite)))
        auxRefinado.append(Int(nrefinado(mes, aceite)))
    comprado.append(auxComprado)
    refinado.append(auxRefinado)

for mes in range(nM + 1):
    auxAlmacen = []
    for aceite in range(nA):
        auxAlmacen.append(Int(nalmacen(mes, aceite)))
    almacen.append(auxAlmacen)

# RESTRICCIONES

# constraint forall (aceite in 1..nA) (almacen[1, aceite] = inicial[aceite]);
for aceite in range(nA):
    s.add(almacen[0][aceite] == inicial[aceite])

for mes in range(nM):
    for aceite in range(nA):
        s.add(comprado[mes][aceite] >= 0)
        s.add(refinado[mes][aceite] >= 0)
        s.add(almacen[mes + 1][aceite] >= 0)
        s.add(almacen[mes + 1][aceite] <= mCap)

# constraint forall (mes in 1..nM, aceite in 1..nA) (almacen[mes+1, aceite] = almacen[mes, aceite] + comprado[mes,aceite] - refinado[mes,aceite]);
for mes in range(nM):
    for aceite in range(nA):
        s.add(
            almacen[mes + 1][aceite]
            == almacen[mes][aceite] + comprado[mes][aceite] - refinado[mes][aceite]
        )

# constraint forall (mes in 1..nM) (refinado[mes, 1] + refinado[mes,2] <= MAXV);
for mes in range(nM):
    s.add(refinado[mes][0] + refinado[mes][1] <= maxV)

# constraint forall (mes in 1..nM) (refinado[mes, 3] + refinado[mes,4] + refinado[mes,5] <= MAXN);
for mes in range(nM):
    s.add(refinado[mes][2] + refinado[mes][3] + refinado[mes][4] <= maxN)

# constraint forall (aceite in 1..nA) (almacen[7, aceite] >= inicial[aceite]*(1-0.01*PV) /\ almacen[7, aceite] <= inicial[aceite]*(1+0.01*PV));
for aceite in range(nA):
    s.add(almacen[6][aceite] <= inicial[aceite] * (1 + 0.01 * pV))
    s.add(almacen[6][aceite] >= inicial[aceite] * (1 - 0.01 * pV))

# constraint beneficio = (sum (mes in 1..nM, aceite in 1..nA) (VALOR * refinado[mes, aceite])
#                       - sum (mes in 1..nM, aceite in 1..nA) (CA * almacen[mes, aceite])
#                       - sum (mes in 1..nM, aceite in 1..nA) (precios[mes, aceite] * comprado[mes, aceite])
#                       );
ventas = valor * addSumMat(refinado)
costeAlmacen = cA * addSumMatRange(almacen, 0, nM, 0, nA)
costeCompras = addInnerProd(precios, comprado)
s.add(beneficio == ventas - costeAlmacen - costeCompras)

# constraint forall (mes in 1..nM) (sum (aceite in 1..nA) (dureza[aceite] * refinado[mes, aceite]) >= sum (aceite in 1..nA) (MinD * refinado[mes, aceite]));
for mes in range(nM):
    s.add(addDotProd(dureza, refinado[mes]) >= minD * addSum(refinado[mes]))
    s.add(addDotProd(dureza, refinado[mes]) <= maxD * addSum(refinado[mes]))

s.add(beneficio >= minB)

## OPTIMIZACION

for mes in range(nM):
    for aceite in range(nA):
        s.add_soft(refinado[mes][aceite] == 0)

if s.check() == unsat:
    print("unsat")
    exit(0)

# SALIDA

NACEITES = ["VEG 1", "VEG 2", "ANV 1", "ANV 2", "ANV 3"]
NMESES = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio"]
header_format = "|{:10}|" + "{:^5}|" * 5
row_format = "|{:10}|" + "{:>5}|" * 5

print(header_format.format("COMPRAS", *NACEITES))
for mes in range(nM):
    print(
        row_format.format(
            NMESES[mes], *[s.model().eval(val).as_string() for val in comprado[mes]]
        )
    )
print()

print(header_format.format("REFINADO", *NACEITES))
for mes in range(nM):
    print(
        row_format.format(
            NMESES[mes], *[s.model().eval(val).as_string() for val in refinado[mes]]
        )
    )

print()

print(header_format.format("ALMACEN", *NACEITES))
print(
    row_format.format(
        "Inicial", *[s.model().eval(val).as_string() for val in almacen[0]]
    )
)
for mes in range(nM):
    print(
        row_format.format(
            NMESES[mes], *[s.model().eval(val).as_string() for val in almacen[mes + 1]]
        )
    )
print()
print("Beneficio: " + s.model().eval(beneficio).as_string())
