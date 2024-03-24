//----------------------------------------------------------
// gravity and planetary bodies.
// dan@marginallyclever.com 2024-03-23
//----------------------------------------------------------

// draws things bigger, makes forces stronger, easier to see what is going on.
float scale=3;

//normally the gravitational constant is 6.67430e-11 m^3 kg^−1 s^−2
float gravity = 60*scale;

// a class to describe a point mass with physical properties.
class PhysicsBody {
  float mass;
  float radius;
  color myColor;
  PImage image;
  
  boolean canMove=true;
  PVector position = new PVector();
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  
  
  PhysicsBody(float mass,float radius,color myColor) {
    this.mass = mass;
    this.radius = radius;
    this.myColor = myColor;
  }
  
  
  void draw() {
    if(image==null) {
      fill(myColor);
      stroke(myColor);
    } else {
      noFill();
      stroke(255,255,255,64);
      image(this.image,
            position.x-radius,
            position.y-radius,
            radius*2,
            radius*2);
    }
    circle(position.x,position.y,radius*2);
    
    noFill();
    pushMatrix();
    translate(position.x,position.y);

    // draw velocity
    stroke(255,0,0);
    line(0,0,velocity.x,velocity.y);

    // draw acceleration
    stroke(255,255,255);
    line(0,0,acceleration.x,acceleration.y);
    
    popMatrix();
  }
  
  void move(float dt) { 
    if(!canMove) return;
    velocity.add(PVector.mult(acceleration,dt));
    position.add(PVector.mult(velocity,dt));
  }
};

ArrayList<PhysicsBody> bodies = new ArrayList<>();

void setup() {
  size(800,800);
  addBodies();
}


void addBodies() {
  PhysicsBody sun = new PhysicsBody(100*scale,30*scale,color(255,255,0));
  bodies.add(sun);
  sun.canMove=false;
  sun.image = loadImage("sun.jpg");
  
  PhysicsBody earth = new PhysicsBody(10*scale,10*scale,color(0,0,255));
  bodies.add(earth);
  earth.position.x = 100*scale;
  earth.image = loadImage("earth.jpg");
  
  PhysicsBody ship = new PhysicsBody(1.0*scale,1*scale,color(0,255,0));
  bodies.add(ship);
  ship.position.x = 115*scale;
  
  earth.velocity.y = initialVelocity(sun,earth);
  ship.velocity.y = initialVelocity(earth,ship)
                  + earth.velocity.y;  // because the ship moves relative to the earth.
  
}


// find the velocity of B such that it will travel in a circular path around A.
// assumes the object starts at the east position (y=0, x>0) and moves only vertically.
float initialVelocity(PhysicsBody a,PhysicsBody b) {
  float r = PVector.sub(a.position,b.position).mag();
  return sqrt(gravity * a.mass / r);
}


void draw() {
  drawBodies();
  doPhysics();
}


void drawBodies() {
  background(0);
  translate(width/2,height/2);
  
  for(PhysicsBody b : bodies) {
    b.draw();
  }
}


void doPhysics() {
  float dt = 1.0/30.0;  // fixed timestep every frame.  assumes 30 fps.
  
  calculateAllForces();
  
  for(PhysicsBody b : bodies) {
    b.move(dt);
  }
}


// calculate gravity forces using Newton's Universal Law of Gravitation
void calculateAllForces() {
  for(PhysicsBody a : bodies) {
    a.acceleration.set(0,0);
  }
  
  for(int i=0; i<bodies.size(); ++i) {
    PhysicsBody a = bodies.get(i);
    // start at i+1 so we never repeat any two pairs of bodies.
    for(int j=i+1; j<bodies.size();++j) {
      PhysicsBody b = bodies.get(j);

      calculateGravityForce(a,b);
    }
  }
}


// the force between bodies A and B.
void calculateGravityForce(PhysicsBody a,PhysicsBody b) {
  PVector direction = PVector.sub(b.position,a.position);
  float distance = direction.mag();
  if(distance<a.radius+b.radius) return;
  
  direction.normalize();
  float forceMagnitude = ( gravity * a.mass * b.mass ) / ( distance * distance );
  PVector force = PVector.mult(direction,forceMagnitude);
  // add the acceleration, taking their relative masses into account. 
  a.acceleration.add(PVector.div(force,a.mass));
  b.acceleration.sub(PVector.div(force,b.mass));
}
