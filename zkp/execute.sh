# rm circuit.r1cs
# rm circuit.sym
# rm circuit_*
# rm -r circuit_*
# rm pot*
# rm proof.json
# rm public.json
# rm verifier.sol
# rm verification_key.json
# rm witness.wtns
# rm parameters.txt

circom circuit.circom --r1cs --wasm --sym --c

cd circuit_js
mv ../input.json ../circuit_js
node generate_witness.js circuit.wasm input.json witness.wtns

mv ../circuit.r1cs ../circuit_js

snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v -e="singularity"

snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

snarkjs groth16 setup circuit.r1cs pot12_final.ptau circuit_0000.zkey

snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="1st Contributor Name" -v -e="singularity"

snarkjs zkey export verificationkey circuit_0001.zkey verification_key.json

snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json

snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol

snarkjs generatecall > output.txt