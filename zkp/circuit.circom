pragma circom 2.0.0;
/*  __    __                                      
   / /_  / /_    ____ ___  ____  ____  ____  __  __
  / __ \/ __ \  / __ `__ \/ __ \/ __ \/ _  \/ / / /
 / /_/ / / / / / / / / / / /_/ / / / /  __ / /_/ / 
/_.___/_/ /_(_)_/ /_/ /_/\____/_/ /_/\____/\__, /  
                                          /____/  */

include "/Users/workstation/node_modules/circomlib/circuits/switcher.circom";
include "/Users/workstation/node_modules/circomlib/circuits/poseidon.circom";

template Hasher() {
  signal input leafX;
  signal input leafY;
  signal input selector;
  signal output newHash;

  component sw = Switcher();
  component hash = Poseidon(2);

  sw.sel <== selector;
  sw.L <== leafX;
  sw.R <== leafY;

  hash.inputs[0] <== sw.outL;
  hash.inputs[1] <== sw.outR;

  newHash <== hash.out;
}

template LeafGenerator() {
  signal input hashW;
  signal input hashX;
  signal input hashY;
  signal input hashZ;
  signal output newHash;

  component leafHash = Poseidon(4);

  leafHash.inputs[0] <== hashW;
  leafHash.inputs[1] <== hashX;
  leafHash.inputs[2] <== hashY;
  leafHash.inputs[3] <== hashZ;

  newHash <== leafHash.out;
}

template HashVerifier() {
  signal input preImage;
  signal input hashValue;
  signal output newHash;

  component verifiedHash = Poseidon(1);

  verifiedHash.inputs[0] <== preImage;

  hashValue === verifiedHash.out;
  newHash <== verifiedHash.out;
}

template MerkleTreeVerifier(nLevels) {
  signal input leaf;
  signal input hashes[nLevels];
  signal input selectors[nLevels];
  signal input root;
    
  component hash[nLevels];

  var proofHash;
  proofHash = leaf;

  for(var i=0; i<nLevels; i++) {
    hash[i] = Hasher();
    hash[i].leafX <== proofHash;
    hash[i].leafY <== hashes[i];
    hash[i].selector <== selectors[i];
    proofHash = hash[i].newHash;
  }

  root === proofHash;
}

template Withdraw(nLevels) {
  signal input address;
  signal input coin;
  signal input amount;
  signal input zeta;
  signal input hashes[nLevels];
  signal input selectors[nLevels];
  signal input root;
  signal input coinPreImage;
  signal input amountPreImage;
  signal input recipient;
  signal input lambda;
  signal output rootRef;

  component amountPrime = HashVerifier();
  amountPrime.preImage <== amountPreImage;
  amountPrime.hashValue <== amount;

  component coinPrime = HashVerifier();
  coinPrime.preImage <== coinPreImage;
  coinPrime.hashValue <== coin;

  component verifiedHash = LeafGenerator();
  verifiedHash.hashW <== address;
  verifiedHash.hashX <== coinPrime.newHash;
  verifiedHash.hashY <== amountPrime.newHash;
  verifiedHash.hashZ <== zeta;

  var leafPrime;
  leafPrime = verifiedHash.newHash;

  component tree = MerkleTreeVerifier(nLevels);
  tree.leaf <== leafPrime;
  for(var i=0; i<nLevels; i++) {
    tree.hashes[i] <== hashes[i];
    tree.selectors[i] <== selectors[i];
  }
  tree.root <== root;

  rootRef <== root;

  signal recipientSquare;
  signal lambdaSquare;
  recipientSquare <== recipient * recipient;
  lambdaSquare <== lambda * lambda;
}

component main = Withdraw(replace);