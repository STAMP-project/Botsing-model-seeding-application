# Search initialization
## All
### worse(4)
#### MATH-1b_frame 2
`HEAVY EXISTING TESTS` - `SECURITY RELATED ISSUE`

Executing the existing test cases are time taking. For instance, Botsing stoped for 60 minutes for the result of the execution of an existing test. Even after that, the test generation was not done.

Also, Botsing throws the following error during the (existing) test execution:
```
Security framework of XStream not initialized, XStream is probably vulnerable
```
#### MATH-61b_frame 3
`HEAVY EXISTING TESTS`

same as previous case.
#### CHART-4b_frame 6
`SECURITY RELATED ISSUE`

Botsing throws the following error during the (existing) test execution:
```
Security framework of XStream not initialized, XStream is probably vulnerable
Exception in thread "Image Fetcher 0" java.lang.ExceptionInInitializerError
	at sun.awt.image.InputStreamImageSource.getDecoder(InputStreamImageSource.java:237)
	at sun.awt.image.URLImageSource.getDecoder(URLImageSource.java:159)
	at sun.awt.image.InputStreamImageSource.doFetch(InputStreamImageSource.java:263)
	at sun.awt.image.ImageFetcher.fetchloop(ImageFetcher.java:205)
	at sun.awt.image.ImageFetcher.run(ImageFetcher.java:169)
Caused by: java.lang.SecurityException: Security manager blocks ("java.lang.RuntimePermission" "loadLibrary.javajpeg")
java.lang.Thread.getStackTrace(Thread.java:1552)
org.evosuite.runtime.sandbox.MSecurityManager.checkPermission(MSecurityManager.java:434)
java.lang.SecurityManager.checkLink(SecurityManager.java:835)
java.lang.Runtime.loadLibrary0(Runtime.java:864)
java.lang.System.loadLibrary(System.java:1122)
sun.awt.image.JPEGImageDecoder$1.run(JPEGImageDecoder.java:59)
sun.awt.image.JPEGImageDecoder$1.run(JPEGImageDecoder.java:57)
java.security.AccessController.doPrivileged(Native Method)
sun.awt.image.JPEGImageDecoder.<clinit>(JPEGImageDecoder.java:56)
sun.awt.image.InputStreamImageSource.getDecoder(InputStreamImageSource.java:237)
sun.awt.image.URLImageSource.getDecoder(URLImageSource.java:159)
sun.awt.image.InputStreamImageSource.doFetch(InputStreamImageSource.java:263)
sun.awt.image.ImageFetcher.fetchloop(ImageFetcher.java:205)
sun.awt.image.ImageFetcher.run(ImageFetcher.java:169)

	at org.evosuite.runtime.sandbox.MSecurityManager.checkPermission(MSecurityManager.java:452)
	at java.lang.SecurityManager.checkLink(SecurityManager.java:835)
	at java.lang.Runtime.loadLibrary0(Runtime.java:864)
	at java.lang.System.loadLibrary(System.java:1122)
	at sun.awt.image.JPEGImageDecoder$1.run(JPEGImageDecoder.java:59)
	at sun.awt.image.JPEGImageDecoder$1.run(JPEGImageDecoder.java:57)
	at java.security.AccessController.doPrivileged(Native Method)
	at sun.awt.image.JPEGImageDecoder.<clinit>(JPEGImageDecoder.java:56)
	... 5 more
```
#### MOCKITO-9b_frame 6
`LACK OF DIVERSITY INT THE OBSERVED CALL SEQUENCES`

Botsing cannot inject the target method into the generated test during the initial population generation.
The target method is same as MOCKITO-10b_frame 11 but the test that we have here is different from MOCKITO-10b. In this tests, the input of target method (Invocation) is only called without any call sequence. On the other hand, Seeding process can detect some sequences in MOCKITO-10b existing test. On the other word, The detected call sequences does not have the proper diversity.

## Test S. 0.5
### worse(1)

#### TIME-20b_frame 1
`HEAVY EXISTING TESTS` - `SECURITY RELATED ISSUE`

Executing the existing test cases are time taking. For instance, Botsing stoped for 60 minutes for the result of the execution of an existing test. Even after that, the test generation was not done.

Also, Botsing throws the following error during the (existing) test execution:
```
Security framework of XStream not initialized, XStream is probably vulnerable
```

## Test S. 0.8
### better(1)

#### MOCKITO-10b_frame 11

`BETTER CHANCE FOR INJECTING TARGET METHOD BECAUSE OF THE USEFULL EXISTING CALL SEQUENCES FOR THE INPUTS OF TARGET METHOD`

We have an existing test which uses the target class. Using this class in initialization helped the search process to generate tests easier. However, it does not mean that test seeding can start the search in 100% of times. Still some randomness are involved. This the reason that why we do not have a significant improvement in the higher test seeding probability.

The existing test `org.mockito.MockingDetailsTest`:
```java
public void testGetInvocations() {
  List<String> methodsInvoked = new ArrayList<String>() {{
    add("add");
    add("remove");
    add("clear");
  }};

  List<String> mockedList = (List<String>) mock(List.class);

  mockedList.add("one");
  mockedList.remove(0);
  mockedList.clear();

  MockingDetails mockingDetails = new MockitoCore().mockingDetails(mockedList);
  Collection<Invocation> invocations = mockingDetails.getInvocations();

  assertNotNull(invocations);
  assertEquals(invocations.size(),3);
  for (Invocation method : invocations) {
    assertTrue(methodsInvoked.contains(method.getMethod().getName()));
    if (method.getMethod().getName().equals("add")) {
      assertEquals(method.getArguments().length,1);
      assertEquals(method.getArguments()[0],"one");
    }
  }
}
```
## Test S. 1.0
### worse(1)

#### TIME-7b_frame 6

`HEAVY EXISTING TESTS` - `SECURITY RELATED ISSUE`

Executing the existing test cases are time taking. For instance, Botsing stoped for 60 minutes for the result of the execution of an existing test. Even after that, the test generation was not done.

Also, Botsing throws the following error during the (existing) test execution:
```
Security framework of XStream not initialized, XStream is probably vulnerable
```


# Crash Reproduction
## All
### worse(3)
#### MATH-1b_frame 2
`HEAVY EXISTING TESTS` - `SECURITY RELATED ISSUE`


Described in the previous Section.
#### MATH-61b_frame 3
`HEAVY EXISTING TESTS`


Described in the previous Section.
#### CHART-4b_frame 6
`SECURITY RELATED ISSUE`

Described in the previous Section.

### better(1)
#### LANG-6b_frame 3
`USE DEFINED VALUES IN THE EXISTING TESTS`

Botsing cannot reproduce this one without test seeding.

The reproducing test is:

```java
String string0 = "\uD842\uDFB7";
   StringEscapeUtils.escapeCsv(string0);
```
The trick is using `string0`

The seeded test is `org.apache.commons.lang3.StringEscapeUtilsTest`. In this test this string was used for testing another method of the target class (`escapeXml`):
```java
public void testLang720() {
    String input = new StringBuilder("\ud842\udfb7").append("A").toString();
    String escaped = StringEscapeUtils.escapeXml(input);
    assertEquals(input, escaped);
}
```

## Test S. 0.2 & 0.5 & 0.8
### better(1)
##### MOCKITO-9b_frame 2
`GENERATE COMPLEX OBJECTS`

Botsing cannot reproduce this one without test seeding.
The seeded test is `org.mockito.internal.stubbing.answers`.

The reproduction test is:
```java
MockitoMethod mockitoMethod0 = mock(MockitoMethod.class, new ViolatedAssumptionAnswer());
int int0 = 0;
RealMethod realMethod0 = mock(RealMethod.class, new ViolatedAssumptionAnswer());
Object object0 = new Object();
Answer<Integer> answer0 = (Answer<Integer>) mock(Answer.class, new ViolatedAssumptionAnswer());
Class<Integer> class0 = Integer.class;
Object[] objectArray0 = new Object[4];
objectArray0[0] = (Object) mockitoMethod0;
objectArray0[2] = object0;
int int1 = 1;
String string0 = "org/mockitousage/IMethods$$EnhancerByMockitoWithCGLIB$$bc35a128";
String string1 = "java/lang/Object";
Class<TypeUtils> class1 = TypeUtils.class;
Class<MethodInterceptor> class2 = MethodInterceptor.class;
Type.getType(class2);
Class<NoOp> class3 = NoOp.class;
Type.getType(class3);
Class<Object> class4 = Object.class;
Type type0 = Type.getType(class4);
String string2 = "Ljava/lang/Object;";
TypeUtils.getPackageName(type0);
Class<IMethods> class5 = IMethods.class;
String string3 = "<method>\n  <class>java.lang.Object</class>\n  <name>finalize</name>\n  <parameter-types/>\n</method>";
Method method0 = (Method)EvoSuiteXStream.fromString(string3);
Type.getMethodDescriptor(method0);
String string4 = "<method>\n  <class>java.lang.Object</class>\n  <name>equals</name>\n  <parameter-types>\n    <class>java.lang.Object</class>\n  </parameter-types>\n</method>";
Method method1 = (Method)EvoSuiteXStream.fromString(string4);
Type.getMethodDescriptor(method1);
String string5 = "<method>\n  <class>java.lang.Object</class>\n  <name>toString</name>\n  <parameter-types/>\n</method>";
Method method2 = (Method)EvoSuiteXStream.fromString(string5);
Type.getMethodDescriptor(method2);
String string6 = "<method>\n  <class>java.lang.Object</class>\n  <name>hashCode</name>\n  <parameter-types/>\n</method>";
Method method3 = (Method)EvoSuiteXStream.fromString(string6);
Type.getMethodDescriptor(method3);
String string7 = "<method>\n  <class>java.lang.Object</class>\n  <name>clone</name>\n  <parameter-types/>\n</method>";
EvoSuiteXStream.fromString(string7);
String string8 = "<method>\n  <class>org.mockitousage.IMethods</class>\n  <name>otherMethod</name>\n  <parameter-types/>\n</method>";
Method method4 = (Method)EvoSuiteXStream.fromString(string8);
objectArray0[1] = (Object) method4;
SerializableMethod serializableMethod0 = new SerializableMethod(method4);
int int2 = 92;
InvocationImpl invocationImpl0 = new InvocationImpl(string7, serializableMethod0, objectArray0, int2, realMethod0);
invocationImpl0.callRealMethod();
```
Target class `InvocationImpl` needs complex input for initializing. These inputs are collected from the test case which is using this target class.
## Test S. 0.8
### better(1)
##### XRENDERING-422_ frame 5
`GENERATE COMPLEX OBJECTS`

Botsing cannot reproduce this one without test seeding.
The reproducing test is:

```java
public void test0() {
    ListenerChain listenerChain0 = new ListenerChain();
    ConsecutiveNewLineStateChainingListener consecutiveNewLineStateChainingListener0 = new ConsecutiveNewLineStateChainingListener(listenerChain0);
    listenerChain0.addListener(consecutiveNewLineStateChainingListener0);
    BlockStateChainingListener blockStateChainingListener0 = new BlockStateChainingListener(listenerChain0);
    listenerChain0.addListener(blockStateChainingListener0);
    HashMap<String, String> hashMap0 = new HashMap<String, String>();
    consecutiveNewLineStateChainingListener0.beginDefinitionList(hashMap0);
    Format format0 = Format.BOLD;
    blockStateChainingListener0.isInTable();
    ListenerChain listenerChain1 = new ListenerChain();
    EmptyBlockChainingListener emptyBlockChainingListener1 = new EmptyBlockChainingListener(listenerChain1);
    Map<String, String> map0 = null;
    blockStateChainingListener0.beginTableCell(map0);
    consecutiveNewLineStateChainingListener0.endTableCell(hashMap0);
    listenerChain0.addListener(emptyBlockChainingListener1);
    consecutiveNewLineStateChainingListener0.endFormat(format0, hashMap0);
}
```
The generated complex objects are coming from the seeded test: `org.xwiki.rendering.listener.chaining.EmptyBlockChainingListenerTest`


# Efficiency

## GENERAL

### worse(31)
`LACK OF DIVERSITY IN THE OBSERVED CALL SEQUENCES (Misguide the search process)` `RANDOMNESS IN TEST SELECTION`
In general, from the Table 4 we can see that by increasing the seeding clone the efficiency is significantly reduced for more cases. For instance with maximum value for seed_clone (1.0) we have lower efficiency for test-seeding in 13 crashes. When we look at these classes, we can see that lots of cloning has been done from the existing tests. however, the seeded call sequences are not close to the test that we should generate. If we have a better diversity in the existing solutions, the crash reproduction could be achieved faster. Also, if we have lots of tests with good diversity (for instance more than our search population), it is possible that the seeding strategy clone other tests which are not close to the path that we want to cover. So, here the randomness can be troublesome.

For example:

#### LANG-12b
The reproducing test for this crash is simple:
```java
int int0 = 1;
String string0 = "";
RandomStringUtils.random(int0, string0);
```
In test S. 1.0 we clone all of the tests from the existing test (`org.apache.commons.lang3.RandomStringUtilsTest`)


### better(22)
`GENERATE COMPLEX OBJECTS`
there are few cases that test seeding outperform compared to no seeding in the efficiency. In these kind of cases we need more complex objects, and the existing tests have some samples of generating these objects. By seeding them in the search process, Botsing can reproduce these crashes faster. However, if we over-use these seeded values, the search process can be misguided.

For example:
#### MATH-4b
The target method needs an object with type `org.apache.commons.math3.geometry.euclidean.threed.SubLine`. This object needs another object with type `org.apache.commons.math3.geometry.euclidean.threed.Segment` for instantiating. Also, Segment needs another 3 other objects to be instantiated.

The seeded test suite is `org.apache.commons.math3.geometry.euclidean.threed.SubLineTest` which is testing the target class, and it is using all of the objects that we want to have as inputs.


## All
### Worse(4)
`HEAVY EXISTING TESTS` - `SECURITY RELATED ISSUE`
Same as Search initialization All Worse.
