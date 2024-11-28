---
title: 'Experimenting with Diffusion Maps for SLAM Loop Closure'
date: 2024-11-27
draft: true
toc: true
categories:
  - computer vision
tags:
  - vslam
  - computer vision
  - machine learning
---

# Introduction

**Loop Closure** is an important part of the pipeline for V-SLAM (Visual-SLAM) systems, where noise and variation in observations causes cumulative drift of our inferred position & map data over time.

For anyone unfamiliar with SLAM in general: **SLAM (Simultaneous Localization and Mapping)** is the conjugate process of *localizing* (finding the local position/s of) and *mapping* (tracking the global position/s of) an agent and it's observations as it progresses through an unknown environment:

![Visual example of the SLAM process, courtesy of Stella-VSLAM](https://j.gifs.com/81m1QL.gif)

This global map of our environment allows us to better refine our position estimates with methods such as [Iterative Closest Point](https://en.wikipedia.org/wiki/Iterative_closest_point), reducing pertubations in such, though in itself isn't immune to errors. Over time, this map can become "desynchronized" from reality, leading to cumulative drift in our estimates:

![Image showing the differences between two SLAM maps, the first without loop closure, the second with](https://www.researchgate.net/profile/Andrey-Bokovoy/publication/318488323/figure/fig1/AS:880941257998338@1587044171278/Solving-SLAM-problem-with-and-without-use-of-the-loop-closure-algorithm-a-A-raw-map.jpg)
<figure><figcaption><i>Above: <b>(a)</b> Map constructed without Loop Closure <b>(b)</b> Map constructed with Loop Closure</i></figcaption></figure>

**Loop Closure** helps address this by adjusting the geometry of our global map as we encounter "familiar" places. If we're observing a place we've seen before, we can compute the discrepancies in our current estimates vs. our previous in the map, and if the difference is large enough - iteratively rectify the map along our trajectory until the geometry is aligned.

# Similarity Measure

Detecting familiar places requires some notion of "similarity" between the two: V-SLAM systems, in mapping the environment, create descriptors of the world around them through various **Feature Detection and Extraction** techniques, providing a great basis upon which we can describe and catalogue "places". As we proceed through the environment, we can compare the aggregated features for our current keyframe (place) against our catalogue of places, indexing anew or correcting, depending on how similar the two feature spaces are.

Dense V-SLAM systems - those which convolve the entire frame, have innate advantages in topological understanding compared to Sparse (though they come with their own set of problems), therefore the focus of this blog will be on Sparse V-SLAM systems. With Sparse V-SLAM, we have (as expected) a sparse set of features that represent the environment, of which we must correspond with prior keyframes:

[insert img here]

The difficulty arises then in discerning the organization or *topology* of the features in the environment: If we've got two keyframes, both from completely different areas of the environment, but the two have incredibly similar features - how do we *realiably* discriminate between the two?

[insert img here]

Doubly-so if we're (hopefully) using some form of homogenous spatial distribution for the feature space, where the keypoints (and thus features) are uniformly distributed through the frame. Here's where the concept of **Diffusion Maps** comes in:

## Diffusion Maps

*Diffusion Maps*