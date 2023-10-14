---
title: ""
date: 2023-01-09T17:23:33Z
draft: true
---

# Multilayer Perceptrons are (pretty much) a form of Boosted Tree with a different objective function
---

Okay, so maybe not that simple. No, definitely not. Multilayer Perceptrons and Boosted Ensembles have multiple nuances/differences in their approach, but strip them back to their core and observe:

<insert diagram>

##### See it?

The other day, I sat there, oogling at a diagram similar to the above, when I realized: If you turn a perceptron on its side... **it's pretty much a n-ary tree**:

<insert diagram>

And then it all clicked. The fact they're function approximators... observe the above again, but consider the context that it's an approximation of a function:

<insert diagram>

Imagine each neuron 