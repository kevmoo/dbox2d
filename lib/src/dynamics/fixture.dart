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
 * A fixture is used to attach a shape to a body for collision detection. A fixture inherits its
 * transform from its parent. Fixtures hold additional non-geometric data such as friction,
 * collision filters, etc. Fixtures are created via Body::CreateFixture.
 * 
 * @warning you cannot reuse fixtures.
 * 
 * @author daniel
 */
class Fixture {
  double m_density = 0.0;

  Fixture m_next;
  Body m_body;

  Shape m_shape;

  double m_friction = 0.0;
  double m_restitution = 0.0;

  List<FixtureProxy> m_proxies;
  int m_proxyCount = 0;

  final Filter m_filter = new Filter();

  bool m_isSensor = false;

  Object m_userData;

  /**
   * Get the type of the child shape. You can use this to down cast to the concrete shape.
   * 
   * @return the shape type.
   */
  ShapeType getType() {
    return m_shape.getType();
  }

  /**
   * Get the child shape. You can modify the child shape, however you should not change the number
   * of vertices because this will crash some collision caching mechanisms.
   * 
   * @return
   */
  Shape getShape() {
    return m_shape;
  }

  /**
   * Is this fixture a sensor (non-solid)?
   * 
   * @return the true if the shape is a sensor.
   * @return
   */
  bool isSensor() {
    return m_isSensor;
  }

  /**
   * Set if this fixture is a sensor.
   * 
   * @param sensor
   */
  void setSensor(bool sensor) {
    if (sensor != m_isSensor) {
      m_body.setAwake(true);
      m_isSensor = sensor;
    }
  }

  /**
   * Set the contact filtering data. This is an expensive operation and should not be called
   * frequently. This will not update contacts until the next time step when either parent body is
   * awake. This automatically calls refilter.
   * 
   * @param filter
   */
  void setFilterData(final Filter filter) {
    m_filter.set(filter);

    refilter();
  }

  /**
   * Get the contact filtering data.
   * 
   * @return
   */
  Filter getFilterData() {
    return m_filter;
  }

  /**
   * Call this if you want to establish collision that was previously disabled by
   * ContactFilter::ShouldCollide.
   */
  void refilter() {
    if (m_body == null) {
      return;
    }

    // Flag associated contacts for filtering.
    ContactEdge edge = m_body.getContactList();
    while (edge != null) {
      Contact contact = edge.contact;
      Fixture fixtureA = contact.getFixtureA();
      Fixture fixtureB = contact.getFixtureB();
      if (fixtureA == this || fixtureB == this) {
        contact.flagForFiltering();
      }
      edge = edge.next;
    }

    World world = m_body.getWorld();

    if (world == null) {
      return;
    }

    // Touch each proxy so that new pairs may be created
    BroadPhase broadPhase = world.m_contactManager.m_broadPhase;
    for (int i = 0; i < m_proxyCount; ++i) {
      broadPhase.touchProxy(m_proxies[i].proxyId);
    }
  }

  /**
   * Get the parent body of this fixture. This is NULL if the fixture is not attached.
   * 
   * @return the parent body.
   * @return
   */
  Body getBody() {
    return m_body;
  }

  /**
   * Get the next fixture in the parent body's fixture list.
   * 
   * @return the next shape.
   * @return
   */
  Fixture getNext() {
    return m_next;
  }

  void setDensity(double density) {
    assert(density >= 0.9);
    m_density = density;
  }

  double getDensity() {
    return m_density;
  }

  /**
   * Get the user data that was assigned in the fixture definition. Use this to store your
   * application specific data.
   * 
   * @return
   */
  Object getUserData() {
    return m_userData;
  }

  /**
   * Set the user data. Use this to store your application specific data.
   * 
   * @param data
   */
  void setUserData(Object data) {
    m_userData = data;
  }

  /**
   * Test a point for containment in this fixture. This only works for convex shapes.
   * 
   * @param p a point in world coordinates.
   * @return
   */
  bool testPoint(final Vec2 p) {
    return m_shape.testPoint(m_body.m_xf, p);
  }

  /**
   * Cast a ray against this shape.
   * 
   * @param output the ray-cast results.
   * @param input the ray-cast input parameters.
   * @param output
   * @param input
   */
  bool raycast(RayCastOutput output, RayCastInput input, int childIndex) {
    return m_shape.raycast(output, input, m_body.m_xf, childIndex);
  }

  /**
   * Get the mass data for this fixture. The mass data is based on the density and the shape. The
   * rotational inertia is about the shape's origin.
   * 
   * @return
   */
  void getMassData(MassData massData) {
    m_shape.computeMass(massData, m_density);
  }

  /**
   * Get the coefficient of friction.
   * 
   * @return
   */
  double getFriction() {
    return m_friction;
  }

  /**
   * Set the coefficient of friction. This will _not_ change the friction of existing contacts.
   * 
   * @param friction
   */
  void setFriction(double friction) {
    m_friction = friction;
  }

  /**
   * Get the coefficient of restitution.
   * 
   * @return
   */
  double getRestitution() {
    return m_restitution;
  }

  /**
   * Set the coefficient of restitution. This will _not_ change the restitution of existing
   * contacts.
   * 
   * @param restitution
   */
  void setRestitution(double restitution) {
    m_restitution = restitution;
  }

  /**
   * Get the fixture's AABB. This AABB may be enlarge and/or stale. If you need a more accurate
   * AABB, compute it using the shape and the body transform.
   * 
   * @return
   */
  AABB getAABB(int childIndex) {
    assert(childIndex >= 0 && childIndex < m_proxyCount);
    return m_proxies[childIndex].aabb;
  }

  /**
   * Compute the distance from this fixture.
   * 
   * @param p a point in world coordinates.
   * @return distance
   */
  double computeDistance(Vec2 p, int childIndex, Vec2 normalOut) {
    return m_shape.computeDistanceToOut(
        m_body.getTransform(), p, childIndex, normalOut);
  }

  // We need separation create/destroy functions from the constructor/destructor because
  // the destructor cannot access the allocator (no destructor arguments allowed by C++).

  void create(Body body, FixtureDef def) {
    m_userData = def.userData;
    m_friction = def.friction;
    m_restitution = def.restitution;

    m_body = body;
    m_next = null;

    m_filter.set(def.filter);

    m_isSensor = def._isSensor;

    m_shape = def.shape.clone();

    // Reserve proxy space
    int childCount = m_shape.getChildCount();
    if (m_proxies == null) {
      m_proxies = new List<FixtureProxy>(childCount);
      for (int i = 0; i < childCount; i++) {
        m_proxies[i] = new FixtureProxy();
        m_proxies[i].fixture = null;
        m_proxies[i].proxyId = BroadPhase.NULL_PROXY;
      }
    }

    if (m_proxies.length < childCount) {
      List<FixtureProxy> old = m_proxies;
      int newLen = Math.max(old.length * 2, childCount);
      m_proxies = new List<FixtureProxy>(newLen);
      Settings.arraycopy(old, 0, m_proxies, 0, old.length);
      for (int i = 0; i < newLen; i++) {
        if (i >= old.length) {
          m_proxies[i] = new FixtureProxy();
        }
        m_proxies[i].fixture = null;
        m_proxies[i].proxyId = BroadPhase.NULL_PROXY;
      }
    }
    m_proxyCount = 0;

    m_density = def.density;
  }

  void destroy() {
    // The proxies must be destroyed before calling this.
    assert(m_proxyCount == 0);

    // Free the child shape.
    m_shape = null;
    m_proxies = null;
    m_next = null;

    // TODO pool shapes
    // TODO pool fixtures
  }

  // These support body activation/deactivation.
  void createProxies(BroadPhase broadPhase, final Transform xf) {
    assert(m_proxyCount == 0);

    // Create proxies in the broad-phase.
    m_proxyCount = m_shape.getChildCount();

    for (int i = 0; i < m_proxyCount; ++i) {
      FixtureProxy proxy = m_proxies[i];
      m_shape.computeAABB(proxy.aabb, xf, i);
      proxy.proxyId = broadPhase.createProxy(proxy.aabb, proxy);
      proxy.fixture = this;
      proxy.childIndex = i;
    }
  }

  /**
   * Internal method
   * 
   * @param broadPhase
   */
  void destroyProxies(BroadPhase broadPhase) {
    // Destroy proxies in the broad-phase.
    for (int i = 0; i < m_proxyCount; ++i) {
      FixtureProxy proxy = m_proxies[i];
      broadPhase.destroyProxy(proxy.proxyId);
      proxy.proxyId = BroadPhase.NULL_PROXY;
    }

    m_proxyCount = 0;
  }

  final AABB _pool1 = new AABB();
  final AABB _pool2 = new AABB();
  final Vec2 _displacement = new Vec2.zero();

  /**
   * Internal method
   * 
   * @param broadPhase
   * @param xf1
   * @param xf2
   */
  void synchronize(BroadPhase broadPhase, final Transform transform1,
      final Transform transform2) {
    if (m_proxyCount == 0) {
      return;
    }

    for (int i = 0; i < m_proxyCount; ++i) {
      FixtureProxy proxy = m_proxies[i];

      // Compute an AABB that covers the swept shape (may miss some rotation effect).
      final AABB aabb1 = _pool1;
      final AABB aab = _pool2;
      m_shape.computeAABB(aabb1, transform1, proxy.childIndex);
      m_shape.computeAABB(aab, transform2, proxy.childIndex);

      proxy.aabb.lowerBound.x = aabb1.lowerBound.x < aab.lowerBound.x
          ? aabb1.lowerBound.x
          : aab.lowerBound.x;
      proxy.aabb.lowerBound.y = aabb1.lowerBound.y < aab.lowerBound.y
          ? aabb1.lowerBound.y
          : aab.lowerBound.y;
      proxy.aabb.upperBound.x = aabb1.upperBound.x > aab.upperBound.x
          ? aabb1.upperBound.x
          : aab.upperBound.x;
      proxy.aabb.upperBound.y = aabb1.upperBound.y > aab.upperBound.y
          ? aabb1.upperBound.y
          : aab.upperBound.y;
      _displacement.x = transform2.p.x - transform1.p.x;
      _displacement.y = transform2.p.y - transform1.p.y;

      broadPhase.moveProxy(proxy.proxyId, proxy.aabb, _displacement);
    }
  }
}
