# Search initialization
## All

### better(1)
#### XWIKI-14626_ frame 5
`multiple information sources`

no-seeding cannot start the search process in any experiment. But, model-seeding is always successful in this task. There is no test case for the target class of this crash, but Botsing static analyzer found some usages of this class in the source code to generate the model. hence, the search process used the abstract test cases drived from the model to generate the initial population.


## Model S. 0.5, 0.8 & 1.0
### better (1)
#### XWIKI-13193_ frame 1
`multiple information sources`

These configurations of model seeding can initialize the search process more frequent than no-seeding and model-seeding 0.2 because they are using the information in the model with higher probability. The reason is same as the previous case. We do not have test, but model-seeding found some usages from the source code.



## Model S. 0.2, 0.8 & 1.0
### better (1)
#### MATH_32b_ frame 10
`multiple information sources`

Only these two configurations can instantiate the target method. The reason is same as the previous case. the target class (`org.apache.commons.math3.geometry.partitioning.AbstractRegion`) usage is only available in the source code and consequently in the model.



## Model S. 0.2
### worse (1)
#### MATH_8b_ frame 1
`no class usage available`

Botsing cannot instantiate the target method all of the time. It is a random process. We do not have any available target class usage even in the model.


# Crash reproduction
In total, we have __9__ new crashes that we can reproduce with different configurations of model seeding:
```
XWIKI-14556 (2,8,10)
XRENDERING-422 (2)
Xwiki-13377 (2, 5)
Mockito-10b (all)
LANG-9b (all)
LANG-20b (2)
XRENDERING-481 (5 8)
XWIKI-12482 (5 8 10)
LANG-19b (5 10)
```
Also there is one case that model-seeding cannot reproduce it at all: `MATH-79b`
According to our manual analysis, this test is flaky.

## All
### better(2)
#### Mockito-10b_ frame 2
[`Prioritize call sequences`], [`multiple information sources`], [`diversity`]
no-seeding and test-seeding cannot reproduce this crash at all. However, model-seeding can replicate it. There is no test for the target class. but there are lots of models of classes in the stack trace to be used for seeding.
The non-minimized test is :
```java
Class<Integer> class0 = Integer.class;
Class<Object> class1 = Object.class;
Class<Integer> class2 = Integer.class;
MockSettingsImpl<String> mockSettingsImpl0 = new MockSettingsImpl<String>();
String string0 = "";
Object[] objectArray0 = new Object[13];
objectArray0[4] = (Object) string0;
objectArray0[5] = (Object) string0;
objectArray0[8] = (Object) class0;
VerboseMockInvocationLogger verboseMockInvocationLogger0 = new VerboseMockInvocationLogger();
Class<String> class3 = String.class;
Class<String> class4 = String.class;
boolean boolean0 = true;
MockCreationValidator mockCreationValidator0 = new MockCreationValidator();
Set<Class> set0 = mockSettingsImpl0.getExtraInterfaces();
boolean boolean1 = true;
Class<Locale.LanguageRange> class5 = Locale.LanguageRange.class;
mockCreationValidator0.validateSerializable(class5, boolean0);
Class<String> class6 = String.class;
mockCreationValidator0.validateType(class1);
Class<Object> class7 = Object.class;
mockCreationValidator0.validateExtraInterfaces(class7, set0);
Class<String> class8 = String.class;
mockCreationValidator0.validateSerializable(class4, boolean0);
Object object0 = null;
mockCreationValidator0.validateDelegatedInstance(class1, object0);
Class<VerificationAwareInvocation> class9 = VerificationAwareInvocation.class;
mockCreationValidator0.validateDelegatedInstance(class9, objectArray0[7]);
Class<Object> class10 = Object.class;
Class<Integer> class11 = Integer.class;
mockCreationValidator0.validateExtraInterfaces(class11, set0);
mockCreationValidator0.validateType(class10);
Class<String> class12 = String.class;
mockCreationValidator0.validateMockedType(class9, class9);
mockCreationValidator0.validateMockedType(class10, string0);
Class<Integer> class13 = Integer.class;
boolean boolean2 = false;
mockCreationValidator0.validateSerializable(class13, boolean2);
mockCreationValidator0.validateExtraInterfaces(class2, set0);
```
Botsing tried the seeded call sequences more frequently until it generates a proper input (`class5`) for the target method.

#### LANG-9b_ frame 10
[`Prioritize call sequences`]
The generated test by __model_seeding__ is:
```java
public void test0()  throws Throwable  {
    Locale locale0 = FastDateParser.JAPANESE_IMPERIAL;
    TimeZone timeZone0 = TimeZone.getTimeZone("!Y");
    FastDateFormat.getInstance("G]", timeZone0, locale0);
}
```
And, the generated test by __test_seeding__ is:
```java
Locale locale0 = Locale.CANADA;
SimpleTimeZone simpleTimeZone0 = (SimpleTimeZone)TimeZone.getDefault();
String string0 = " ,(\"/>$T'1<G m";
FastDateFormat.getInstance(string0, (TimeZone) simpleTimeZone0, locale0);
```



`string0` should contain 'G' char.  
`Locale locale0 = FastDateParser.JAPANESE_IMPERIAL` is necessary.

__Why model-seeding can replicate this crash?__  
It is because we have `FastDateParser.JAPANESE_IMPERIAL` as one of the options for setting the Locale object.

Why we did not have this option previously?  It is because in this frame our target class is `FastDateFormat`, and `JAPANESE_IMPERIAL` was available in `FastDateParser`. Since EvoSuite is a Unit Testing tool, it does not check other classes for potential values to use.

Why we have it in model_seeding?  `FastDateParser` object is in our stack trace. We generate 100 test cases for each of the objects in the stack trace. In one of this test cases for `FastDateParser`, we randomly use `FastDateParser.JAPANESE_IMPERIAL` and put this test case in our pool.


### worse(1)
#### MATH-79b (2)
This crash is replicated only once by no-seeding. When we run it on the source code we can see that it is flakey test. The generated stack trace is different each time.
the generated test sometimes generate this tack trace:

```
java.lang.NullPointerException
	at org.apache.commons.math.stat.clustering.EuclideanIntegerPoint.distanceFrom(EuclideanIntegerPoint.java:57)
	at org.apache.commons.math.stat.clustering.EuclideanIntegerPoint.distanceFrom(EuclideanIntegerPoint.java:30)
	at org.apache.commons.math.stat.clustering.KMeansPlusPlusClusterer.getNearestCluster(KMeansPlusPlusClusterer.java:156)
	at org.apache.commons.math.stat.clustering.KMeansPlusPlusClusterer.assignPointsToClusters(KMeansPlusPlusClusterer.java:90)
	at org.apache.commons.math.stat.clustering.KMeansPlusPlusClusterer.cluster(KMeansPlusPlusClusterer.java:57)
```

somtime:

```
	java.lang.NullPointerException
		at org.apache.commons.math.stat.clustering.KMeansPlusPlusClusterer.assignPointsToClusters(KMeansPlusPlusClusterer.java:91)
		at org.apache.commons.math.stat.clustering.KMeansPlusPlusClusterer.cluster(KMeansPlusPlusClusterer.java:57)
```
sometimes:
```
	java.lang.ArrayIndexOutOfBoundsException: 6

	at org.apache.commons.math.util.MathUtils.distance(MathUtils.java:1626)
	at org.apache.commons.math.stat.clustering.EuclideanIntegerPoint.distanceFrom(EuclideanIntegerPoint.java:57)
	at org.apache.commons.math.stat.clustering.EuclideanIntegerPoint.distanceFrom(EuclideanIntegerPoint.java:30)
	at org.apache.commons.math.stat.clustering.KMeansPlusPlusClusterer.getNearestCluster(KMeansPlusPlusClusterer.java:156)
	at org.apache.commons.math.stat.clustering.KMeansPlusPlusClusterer.assignPointsToClusters(KMeansPlusPlusClusterer.java:90)
	at org.apache.commons.math.stat.clustering.KMeansPlusPlusClusterer.cluster(KMeansPlusPlusClusterer.java:57)
```
## Model S. .2,.8 & 1
### better(1)
#### XWIKI-14556_ frame 6
`multiple information sources`

No-seeding cannot replicate this crash. There is no test for the target class `HqlQueryExecutor`. however, we have a model for it which is fetched from the source code analysis.
The generated test by model-seeding is:

```java
HqlQueryExecutor hqlQueryExecutor0 = new HqlQueryExecutor();
			String string0 = ",";
			DefaultQuery defaultQuery0 = new DefaultQuery(string0, hqlQueryExecutor0);
			String string1 = "i";
			DefaultQuery defaultQuery1 = (DefaultQuery)defaultQuery0.bindValue(string1, (Object) hqlQueryExecutor0);
			HiddenSpaceFilter hiddenSpaceFilter0 = new HiddenSpaceFilter();
			ConfigurationSource configurationSource0 = mock(ConfigurationSource.class, new ViolatedAssumptionAnswer());
			doReturn((Object) null).when(configurationSource0).getProperty(anyString() , nullable(Class.class));
			Injector.inject(hiddenSpaceFilter0, (Class<?>) AbstractHiddenFilter.class, "userPreferencesSource", (Object) configurationSource0);
			LinkedBlockingDeque<SubstituteLoggingEvent> linkedBlockingDeque0 = new LinkedBlockingDeque<SubstituteLoggingEvent>();
			boolean boolean0 = false;
			SubstituteLoggingEvent substituteLoggingEvent0 = new SubstituteLoggingEvent();
			linkedBlockingDeque0.put(substituteLoggingEvent0);
			linkedBlockingDeque0.getLast();
			SubstituteLogger substituteLogger0 = new SubstituteLogger(string0, linkedBlockingDeque0, boolean0);
			Injector.inject(hiddenSpaceFilter0, (Class<?>) AbstractWhereQueryFilter.class, "logger", (Object) substituteLogger0);
			Injector.validateBean(hiddenSpaceFilter0, (Class<?>) HiddenSpaceFilter.class);
			hiddenSpaceFilter0.initialize();
			Vector<EscapeLikeParametersFilter> vector0 = new Vector<EscapeLikeParametersFilter>();
			String string2 = "cg2J]/*h4ILwH.`JL";
			Query query0 = mock(Query.class, new ViolatedAssumptionAnswer());
			doReturn((Query) null).when(query0).setParameter(anyString() , any());
			SessionImplementor sessionImplementor0 = mock(SessionImplementor.class, new ViolatedAssumptionAnswer());
			OrdinalParameterDescriptor[] ordinalParameterDescriptorArray0 = null;
			AtomicHashMap<UserComponentManager, ScriptQueryParameter> atomicHashMap0 = new AtomicHashMap<UserComponentManager, ScriptQueryParameter>();
			ParameterMetadata parameterMetadata0 = new ParameterMetadata(ordinalParameterDescriptorArray0, atomicHashMap0);
			CollectionFilterImpl collectionFilterImpl0 = new CollectionFilterImpl(string2, defaultQuery1, sessionImplementor0, parameterMetadata0);
			hqlQueryExecutor0.populateParameters(collectionFilterImpl0, defaultQuery1);
```

## Model S. .5,.8 & 1
### better(1)
#### XWIKI-12482_ frame 4
`multiple information sources`

Target class is the same as the previous case. The reason is the same as well.



## Model S. .2,.5 & 1
### worse(1)
#### XWIKI-8281 frame 1
`Fixed number of seeded abstract test cases`


No seeding and model seeding 0.8 can replicate this crash 1/30 times. The generated test is:
```java
	 DocumentReference documentReference0 = Mockito.mock(DocumentReference.class, new ViolatedAssumptionAnswer());
	 Mockito.doReturn((Locale) null).when(documentReference0).getLocale();
	 XWikiDocument xWikiDocument0 = new XWikiDocument(documentReference0);
	 String string0 = xWikiDocument0.getParent();
	 xWikiDocument0.setAuthor(string0);
	 xWikiDocument0.setSyntaxId(string0);
	 int int0 = 605;
	 xWikiDocument0.getDocumentSection(int0);
```
The model for the target class is big. Since we set size 100 for the generated abstract test cases from the model, it is possible to miss this sequence and it leads to misguide the search process because it chose another unfavorable paths in the model for generating the abstract test cases.


## Model S. .2,.5
### better(1)
#### XWIKI-13377 frame 3

[`Multiple information resources`]


In this case, target class is `XWiki`.

There are lots of tests exported from model. All of these paths came from the statical analysis from the source code.

Example for test:

```java
XWikiContext xWikiContext0 = null;
XWikiEngineContext xWikiEngineContext0 = mock(XWikiEngineContext.class, new ViolatedAssumptionAnswer());
boolean boolean0 = true;
XWiki xWiki0 = new XWiki(xWikiContext0, xWikiEngineContext0, boolean0);
String string0 = "#;!:vg;\\o";
xWiki0.exists(string0, xWikiContext0);
```


## Model S. .5, .8
### better(1)
#### XRENDERING-481 frame 2
[`Multiple information resources`]
Same as XWIKI-12482



## Model S. .5, 1
### better(1)
#### LANG-19b frame 3
[`Multiple information resources`]


The target method is `translate()` this method is defined with the various input parameteres. Some of them are available in the existing test. However, the one that we need for the replication (`translate(CharSequence input)`) is available in the source code.



## Test S. .2
### better(2)
##### XRENDERING-422_ frame 5
`GENERATE COMPLEX OBJECTS`
Described in the test seeding manual analysis.


#### LANG-20_frame 2
[`Multiple information resources`]

the target class has lots of usages in the existing tests (the list of tests are available in the following list). However, test seeding cannot replicate this crash. only model-seeding is capable of doing this task.

```
"org.apache.commons.lang3.StringUtilsTrimEmptyTest"
"org.apache.commons.lang3.StringUtilsIsTest"
"org.apache.commons.lang3.StringUtilsStartsEndsWithTest"
"org.apache.commons.lang3.StringUtilsEqualsIndexOfTest"
"org.apache.commons.lang3.StringUtilsSubstringTest"
"org.apache.commons.lang3.StringUtilsTest"
"org.apache.commons.lang3.exception.ContextedRuntimeExceptionTest"
"org.apache.commons.lang3.exception.ContextedExceptionTest"
```

The generated test by model-seeding is:
```java
Class<Integer> class0 = Integer.class;
			Consumer<Object> consumer0 = (Consumer<Object>) Mockito.mock(Consumer.class, new ViolatedAssumptionAnswer());
			Mockito.doReturn((String) null).when(consumer0).toString();
			Class<Object> class2 = Object.class;
			ServiceLoader.load(class2);
			String string4 = "@c<T&eG ^-";
			char char0 = '\u008B';
			String string5 = "o(4tvR($6l1Q";

			char[] charArray0 = new char[6];
			charArray0[3] = char0;
			charArray0[5] = charArray0[4];
			Object[] objectArray0 = new Object[7];
			objectArray0[0] = (Object) consumer0;
			objectArray0[1] = (Object) string5;
			Object object0 = new Object();
			objectArray0[4] = object0;
			objectArray0[5] = (Object) class0;
			objectArray0[6] = (Object) charArray0[0];
			StringUtils.join(objectArray0, string4);
```

We are using the models of classes in java in model seeding. As we can see in the generated test, we have  lots of sequences and objects generated from the classes in the java library to pass to the target method. Finally, one of them `Consumer<Object>` generated a value which trigger the given exception in the target class.

# Efficiency

## all

### better(2)

#### MOCKITO-10b
Described in the crash reproduction section.

#### XWIKI-13141_ frame 1
[`Multiple information resources`]
The seeded abstract test cases from model to the initial population helps botsing to replicate the crash in the first 100 ff evaluations. Also, diversity of the selected abstract test cases guaranties that we will have the path that we want always in the object pool.
