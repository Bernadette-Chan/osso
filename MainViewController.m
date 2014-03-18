//
//  MainViewController.m
//  osso
//
//  Created by Jordan Delcros on 16/03/2014.
//  Copyright (c) 2014 Jordan Delcros. All rights reserved.
//

#import "MainViewController.h"
#import "cube.h"

@interface MainViewController()
{
    
    GLKMatrix4 _rotationMatrix;
    
//    float _rotateX;
//    float _rotateY;
//    float _rotateZ;
    
}

@property (strong, nonatomic) GLKBaseEffect* effect;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Set up context
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    
    // Set up view
    GLKView* glkview = (GLKView *)self.view;
    glkview.context = context;
    
    // OpennGL ES settings
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    
    glEnable(GL_CULL_FACE);
    
    // Create effect
    [self createEffect];
    
    // Variables
    //_rotateX = 0.0f;
    //_rotateY = 0.0f;
    //_rotateZ = 0.0f;
    _rotationMatrix = GLKMatrix4Identity;
    
}

- (void)createEffect
{
    
    // Initialize
    self.effect = [[GLKBaseEffect alloc] init];
    
    NSDictionary* options = @{ GLKTextureLoaderOriginBottomLeft: @YES };
    NSError* error;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"cube.png" ofType:nil];
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    if( texture == nil ){
        
        NSLog(@"Error loading file %@", [error localizedDescription]);
        
    }
    
    self.effect.texture2d0.name = texture.name;
    self.effect.texture2d0.enabled = true;

    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.position = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.lightingType = GLKLightingTypePerPixel;
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Prepare effect
    [self.effect prepareToDraw];
    
    // Set matrice
    [self setMatrices];
    
    // Positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, cubePositions);
    
    // Texels
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, cubeTexels);
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, cubeNormals);
    
    // Draw model
    glDrawArrays(GL_TRIANGLES, 0, cubeVertices);
    
}

- (void)setMatrices
{
    
    // Projection Matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // ModelView matrix
/*    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, -5.0f);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, GLKMathDegreesToRadians(_rotateX));
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(_rotateY));
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(_rotateZ));
*/
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, _rotationMatrix);
    self.effect.transform.modelviewMatrix = modelViewMatrix;

}

- (void)update
{
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch * touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self.view];
    CGPoint lastLocation = [touch previousLocationInView:self.view];
    CGPoint difference = CGPointMake(lastLocation.x - location.x, lastLocation.y - location.y);
    
    float rotationX = -1 * GLKMathDegreesToRadians(difference.y  / 2.0);
    float rotationY = -1 * GLKMathDegreesToRadians(difference.x / 2.0);
    
    BOOL isInvertible;
    GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotationMatrix, &isInvertible), GLKVector3Make(1.0, 0.0, 0.0));
    _rotationMatrix = GLKMatrix4Rotate(_rotationMatrix, rotationX, xAxis.x, xAxis.y, xAxis.z);
    GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotationMatrix, &isInvertible), GLKVector3Make(0.0, 1.0, 0.0));
    _rotationMatrix = GLKMatrix4Rotate(_rotationMatrix, rotationY, yAxis.x, yAxis.y, yAxis.z);

    
}

@end
