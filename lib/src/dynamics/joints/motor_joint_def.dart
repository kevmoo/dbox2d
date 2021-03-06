/*******************************************************************************
 * Copyright (c) 2015, Daniel Murphy, Google
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/

part of box2d;

/**
 * Motor joint definition.
 * 
 * @author dmurph
 */
class MotorJointDef extends JointDef {
  /**
   * Position of bodyB minus the position of bodyA, in bodyA's frame, in meters.
   */
  final Vec2 linearOffset = new Vec2.zero();

  /**
   * The bodyB angle minus bodyA angle in radians.
   */
  double angularOffset = 0.0;

  /**
   * The maximum motor force in N.
   */
  double maxForce = 1.0;

  /**
   * The maximum motor torque in N-m.
   */
  double maxTorque = 1.0;

  /**
   * Position correction factor in the range [0,1].
   */
  double correctionFactor = 0.3;

  MotorJointDef() : super(JointType.MOTOR);

  void initialize(Body bA, Body bB) {
    bodyA = bA;
    bodyB = bB;
    Vec2 xB = bodyB.getPosition();
    bodyA.getLocalPointToOut(xB, linearOffset);

    double angleA = bodyA.getAngle();
    double angleB = bodyB.getAngle();
    angularOffset = angleB - angleA;
  }
}
