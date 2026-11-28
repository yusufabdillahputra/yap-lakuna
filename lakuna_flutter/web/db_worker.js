(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q)){b[q]=a[q]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(Object.getPrototypeOf(r)&&Object.getPrototypeOf(r).p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++){inherit(b[s],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s){A.qu(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a,b){if(b!=null)A.v(a,b)
a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.le(b)
return new s(c,this)}:function(){if(s===null)s=A.le(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.le(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
lj(a,b,c,d){return{i:a,p:b,e:c,x:d}},
ku(a){var s,r,q,p,o,n="_$dart_js",m=a[v.dispatchPropertyName]
if(m==null)if($.lh==null){A.qh()
m=a[v.dispatchPropertyName]}if(m!=null){s=m.p
if(!1===s)return m.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return m.i
if(m.e===r)throw A.b(A.l_("Return interceptor for "+A.u(s(a,m))))}q=a.constructor
if(q==null)p=null
else{o=$.jA
if(o==null)o=$.jA=A.kt(n)
p=q[o]}if(p!=null)return p
p=A.qm(a)
if(p!=null)return p
if(typeof a=="function")return B.a6
s=Object.getPrototypeOf(a)
if(s==null)return B.F
if(s===Object.prototype)return B.F
if(typeof q=="function"){o=$.jA
if(o==null)o=$.jA=A.kt(n)
Object.defineProperty(q,o,{value:B.v,enumerable:false,writable:true,configurable:true})
return B.v}return B.v},
lG(a,b){if(a<0||a>4294967295)throw A.b(A.ac(a,0,4294967295,"length",null))
return J.nL(new Array(a),b)},
nL(a,b){var s=A.v(a,b.h("p<0>"))
s.$flags=1
return s},
nM(a,b){return J.n9(a,b)},
bC(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.cE.prototype
return J.ef.prototype}if(typeof a=="string")return J.aQ.prototype
if(a==null)return J.cF.prototype
if(typeof a=="boolean")return J.ee.prototype
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a9.prototype
if(typeof a=="symbol")return J.bJ.prototype
if(typeof a=="bigint")return J.a3.prototype
return a}if(a instanceof A.d)return a
return J.ku(a)},
dK(a){if(typeof a=="string")return J.aQ.prototype
if(a==null)return a
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a9.prototype
if(typeof a=="symbol")return J.bJ.prototype
if(typeof a=="bigint")return J.a3.prototype
return a}if(a instanceof A.d)return a
return J.ku(a)},
bD(a){if(a==null)return a
if(Array.isArray(a))return J.p.prototype
if(typeof a!="object"){if(typeof a=="function")return J.a9.prototype
if(typeof a=="symbol")return J.bJ.prototype
if(typeof a=="bigint")return J.a3.prototype
return a}if(a instanceof A.d)return a
return J.ku(a)},
qc(a){if(typeof a=="number")return J.cG.prototype
if(typeof a=="string")return J.aQ.prototype
if(a==null)return a
if(!(a instanceof A.d))return J.bj.prototype
return a},
qd(a){if(typeof a=="string")return J.aQ.prototype
if(a==null)return a
if(!(a instanceof A.d))return J.bj.prototype
return a},
mA(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.a9.prototype
if(typeof a=="symbol")return J.bJ.prototype
if(typeof a=="bigint")return J.a3.prototype
return a}if(a instanceof A.d)return a
return J.ku(a)},
N(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.bC(a).X(a,b)},
n8(a,b){if(typeof b==="number")if(Array.isArray(a)||A.mC(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.bD(a).n(a,b)},
lm(a,b,c){if(typeof b==="number")if((Array.isArray(a)||A.mC(a,a[v.dispatchPropertyName]))&&!(a.$flags&2)&&b>>>0===b&&b<a.length)return a[b]=c
return J.bD(a).q(a,b,c)},
ln(a,b){return J.bD(a).E(a,b)},
co(a,b,c){return J.mA(a).dF(a,b,c)},
n9(a,b){return J.qc(a).ae(a,b)},
kL(a,b){return J.bD(a).C(a,b)},
na(a){return J.mA(a).ga5(a)},
a8(a){return J.bC(a).gv(a)},
ak(a){return J.bD(a).gt(a)},
cp(a){return J.dK(a).gk(a)},
nb(a){return J.bC(a).gA(a)},
nc(a,b,c){return J.bD(a).dY(a,b,c)},
nd(a,b,c,d,e){return J.bD(a).D(a,b,c,d,e)},
kM(a,b){return J.bD(a).S(a,b)},
ne(a,b){return J.qd(a).ej(a,b)},
aL(a){return J.bC(a).i(a)},
eb:function eb(){},
ee:function ee(){},
cF:function cF(){},
I:function I(){},
aR:function aR(){},
et:function et(){},
bj:function bj(){},
a9:function a9(){},
a3:function a3(){},
bJ:function bJ(){},
p:function p(a){this.$ti=a},
ed:function ed(){},
hw:function hw(a){this.$ti=a},
dM:function dM(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
cG:function cG(){},
cE:function cE(){},
ef:function ef(){},
aQ:function aQ(){}},A={kR:function kR(){},
lt(a,b,c){if(t.Q.b(a))return new A.db(a,b.h("@<0>").M(c).h("db<1,2>"))
return new A.b6(a,b.h("@<0>").M(c).h("b6<1,2>"))},
lH(a){return new A.bb("Field '"+a+"' has been assigned during initialization.")},
nS(a){return new A.bb("Field '"+a+"' has not been initialized.")},
nR(a){return new A.bb("Field '"+a+"' has already been initialized.")},
aV(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
kZ(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
dJ(a,b,c){return a},
li(a){var s,r
for(s=$.bA.length,r=0;r<s;++r)if(a===$.bA[r])return!0
return!1},
i1(a,b,c,d){A.ah(b,"start")
if(c!=null){A.ah(c,"end")
if(b>c)A.y(A.ac(b,0,c,"start",null))}return new A.d_(a,b,c,d.h("d_<0>"))},
nX(a,b,c,d){if(t.Q.b(a))return new A.cy(a,b,c.h("@<0>").M(d).h("cy<1,2>"))
return new A.bd(a,b,c.h("@<0>").M(d).h("bd<1,2>"))},
lV(a,b,c){var s="count"
if(t.Q.b(a)){A.f9(b,s)
A.ah(b,s)
return new A.bH(a,b,c.h("bH<0>"))}A.f9(b,s)
A.ah(b,s)
return new A.aF(a,b,c.h("aF<0>"))},
ec(){return new A.as("No element")},
lF(){return new A.as("Too few elements")},
aX:function aX(){},
dT:function dT(a,b){this.a=a
this.$ti=b},
b6:function b6(a,b){this.a=a
this.$ti=b},
db:function db(a,b){this.a=a
this.$ti=b},
d8:function d8(){},
ay:function ay(a,b){this.a=a
this.$ti=b},
bb:function bb(a){this.a=a},
kB:function kB(){},
hR:function hR(){},
o:function o(){},
af:function af(){},
d_:function d_(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
bL:function bL(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bd:function bd(a,b,c){this.a=a
this.b=b
this.$ti=c},
cy:function cy(a,b,c){this.a=a
this.b=b
this.$ti=c},
ej:function ej(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
aD:function aD(a,b,c){this.a=a
this.b=b
this.$ti=c},
d4:function d4(a,b,c){this.a=a
this.b=b
this.$ti=c},
d5:function d5(a,b){this.a=a
this.b=b},
aF:function aF(a,b,c){this.a=a
this.b=b
this.$ti=c},
bH:function bH(a,b,c){this.a=a
this.b=b
this.$ti=c},
eA:function eA(a,b){this.a=a
this.b=b},
cz:function cz(a){this.$ti=a},
e3:function e3(){},
cC:function cC(){},
dD:function dD(){},
mM(a){var s=A.mL(a)
if(s!=null)return s
return"minified:"+a},
mC(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.aU.b(a)},
u(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.aL(a)
return s},
cT(a){var s,r=$.lK
if(r==null)r=$.lK=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
eu(a){var s,r,q,p
if(a instanceof A.d)return A.ae(A.bE(a),null)
s=J.bC(a)
if(s===B.a5||s===B.a7||t.ak.b(a)){r=B.w(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.ae(A.bE(a),null)},
lR(a){var s,r,q
if(a==null||typeof a=="number"||A.kj(a))return J.aL(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.b7)return a.i(0)
if(a instanceof A.dq)return a.dA(!0)
s=$.n5()
for(r=0;r<1;++r){q=s[r].hU(a)
if(q!=null)return q}return"Instance of '"+A.eu(a)+"'"},
o2(a,b,c){var s,r,q,p
if(c<=500&&b===0&&c===a.length)return String.fromCharCode.apply(null,a)
for(s=b,r="";s<c;s=q){q=s+500
p=q<c?q:c
r+=String.fromCharCode.apply(null,a.subarray(s,p))}return r},
bh(a){var s
if(0<=a){if(a<=65535)return String.fromCharCode(a)
if(a<=1114111){s=a-65536
return String.fromCharCode((B.b.G(s,10)|55296)>>>0,s&1023|56320)}}throw A.b(A.ac(a,0,1114111,null,null))},
bg(a){if(a.date===void 0)a.date=new Date(a.a)
return a.date},
lQ(a){var s=A.bg(a).getFullYear()+0
return s},
lO(a){var s=A.bg(a).getMonth()+1
return s},
lL(a){var s=A.bg(a).getDate()+0
return s},
lM(a){var s=A.bg(a).getHours()+0
return s},
lN(a){var s=A.bg(a).getMinutes()+0
return s},
lP(a){var s=A.bg(a).getSeconds()+0
return s},
o0(a){var s=A.bg(a).getMilliseconds()+0
return s},
o1(a){var s=A.bg(a).getDay()+0
return B.b.bV(s+6,7)+1},
o_(a){var s=a.$thrownJsError
if(s==null)return null
return A.Q(s)},
ev(a,b){var s
if(a.$thrownJsError==null){s=new Error()
A.L(a,s)
a.$thrownJsError=s
s.stack=b.i(0)}},
lg(a,b){var s,r="index",q=null
if(!A.la(b))return new A.al(!0,b,r,q)
s=J.cp(a)
if(b<0||b>=s)return A.e9(b,s,a,q,r)
return new A.bP(q,q,!0,b,r,"Value not in range")},
q9(a,b,c){if(a>c)return A.ac(a,0,c,"start",null)
if(b!=null)if(b<a||b>c)return A.ac(b,a,c,"end",null)
return new A.al(!0,b,"end",null)},
b(a){return A.L(a,new Error())},
L(a,b){var s
if(a==null)a=new A.aG()
b.dartException=a
s=A.qw
if("defineProperty" in Object){Object.defineProperty(b,"message",{get:s})
b.name=""}else b.toString=s
return b},
qw(){return J.aL(this.dartException)},
y(a,b){throw A.L(a,b==null?new Error():b)},
E(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.y(A.p4(a,b,c),s)},
p4(a,b,c){var s,r,q,p,o,n,m,l,k
if(typeof b=="string")s=b
else{r="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
q=r.length
p=b
if(p>q){c=p/q|0
p%=q}s=r[p]}o=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
n=t.j.b(a)?"list":"ByteData"
m=a.$flags|0
l="a "
if((m&4)!==0)k="constant "
else if((m&2)!==0){k="unmodifiable "
l="an "}else k=(m&1)!==0?"fixed-length ":""
return new A.d1("'"+s+"': Cannot "+o+" "+l+k+n)},
T(a){throw A.b(A.a5(a))},
aH(a){var s,r,q,p,o,n
a=A.qq(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.v([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.ic(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
id(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
m0(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
kS(a,b){var s=b==null,r=s?null:b.method
return new A.eg(a,r,s?null:b.receiver)},
R(a){if(a==null)return new A.hG(a)
if(a instanceof A.cA)return A.b2(a,a.a)
if(typeof a!=="object")return a
if("dartException" in a)return A.b2(a,a.dartException)
return A.pN(a)},
b2(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
pN(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.b.G(r,16)&8191)===10)switch(q){case 438:return A.b2(a,A.kS(A.u(s)+" (Error "+q+")",null))
case 445:case 5007:A.u(s)
return A.b2(a,new A.cR())}}if(a instanceof TypeError){p=$.mQ()
o=$.mR()
n=$.mS()
m=$.mT()
l=$.mW()
k=$.mX()
j=$.mV()
$.mU()
i=$.mZ()
h=$.mY()
g=p.W(s)
if(g!=null)return A.b2(a,A.kS(s,g))
else{g=o.W(s)
if(g!=null){g.method="call"
return A.b2(a,A.kS(s,g))}else if(n.W(s)!=null||m.W(s)!=null||l.W(s)!=null||k.W(s)!=null||j.W(s)!=null||m.W(s)!=null||i.W(s)!=null||h.W(s)!=null)return A.b2(a,new A.cR())}return A.b2(a,new A.eC(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.cY()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.b2(a,new A.al(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.cY()
return a},
Q(a){var s
if(a instanceof A.cA)return a.b
if(a==null)return new A.du(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.du(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
mF(a){if(a==null)return J.a8(a)
if(typeof a=="object")return A.cT(a)
return J.a8(a)},
pe(a,b,c,d,e,f){switch(b){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.b(A.ny("Unsupported number of arguments for wrapped closure"))},
b1(a,b){var s
if(a==null)return null
s=a.$identity
if(!!s)return s
s=A.q7(a,b)
a.$identity=s
return s},
q7(a,b){var s
switch(b){case 0:s=a.$0
break
case 1:s=a.$1
break
case 2:s=a.$2
break
case 3:s=a.$3
break
case 4:s=a.$4
break
default:s=null}if(s!=null)return s.bind(a)
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.pe)},
nn(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.hX().constructor.prototype):Object.create(new A.cs(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.lw(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.nj(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.lw(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
nj(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.b("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.ng)}throw A.b("Error in functionType of tearoff")},
nk(a,b,c,d){var s=A.ls
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
lw(a,b,c,d){if(c)return A.nm(a,b,d)
return A.nk(b.length,d,a,b)},
nl(a,b,c,d){var s=A.ls,r=A.nh
switch(b?-1:a){case 0:throw A.b(new A.ex("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
nm(a,b,c){var s,r
if($.lq==null)$.lq=A.lp("interceptor")
if($.lr==null)$.lr=A.lp("receiver")
s=b.length
r=A.nl(s,c,a,b)
return r},
le(a){return A.nn(a)},
ng(a,b){return A.dB(v.typeUniverse,A.bE(a.a),b)},
ls(a){return a.a},
nh(a){return a.b},
lp(a){var s,r,q,p=new A.cs("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.b(A.a0("Field name "+a+" not found.",null))},
kt(a){return v.getIsolateTag(a)},
qy(a,b){var s=$.l
if(s===B.a)return a
return s.cp(a,b)},
mJ(){return v.G},
r7(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
qm(a){var s,r,q,p,o,n=$.mB.$1(a),m=$.ks[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.kz[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=$.mw.$2(a,n)
if(q!=null){m=$.ks[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.kz[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.kA(s)
$.ks[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.kz[n]=s
return s}if(p==="-"){o=A.kA(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.mG(a,s)
if(p==="*")throw A.b(A.l_(n))
if(v.leafTags[n]===true){o=A.kA(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.mG(a,s)},
mG(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.lj(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
kA(a){return J.lj(a,!1,null,!!a.$iaa)},
qo(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.kA(s)
else return J.lj(s,c,null,null)},
qh(){if(!0===$.lh)return
$.lh=!0
A.qi()},
qi(){var s,r,q,p,o,n,m,l
$.ks=Object.create(null)
$.kz=Object.create(null)
A.qg()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.mI.$1(o)
if(n!=null){m=A.qo(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
qg(){var s,r,q,p,o,n,m=B.K()
m=A.cj(B.L,A.cj(B.M,A.cj(B.x,A.cj(B.x,A.cj(B.N,A.cj(B.O,A.cj(B.P(B.w),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.mB=new A.kw(p)
$.mw=new A.kx(o)
$.mI=new A.ky(n)},
cj(a,b){return a(b)||b},
q8(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
qq(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
W:function W(a,b){this.a=a
this.b=b},
dr:function dr(a,b){this.a=a
this.b=b},
ds:function ds(a,b){this.a=a
this.b=b},
ca:function ca(a,b){this.a=a
this.b=b},
eU:function eU(a,b){this.a=a
this.b=b},
cv:function cv(){},
cw:function cw(a,b,c){this.a=a
this.b=b
this.$ti=c},
dh:function dh(a,b){this.a=a
this.$ti=b},
eP:function eP(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
cV:function cV(){},
ic:function ic(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
cR:function cR(){},
eg:function eg(a,b,c){this.a=a
this.b=b
this.c=c},
eC:function eC(a){this.a=a},
hG:function hG(a){this.a=a},
cA:function cA(a,b){this.a=a
this.b=b},
du:function du(a){this.a=a
this.b=null},
b7:function b7(){},
fl:function fl(){},
fm:function fm(){},
i2:function i2(){},
hX:function hX(){},
cs:function cs(a,b){this.a=a
this.b=b},
ex:function ex(a){this.a=a},
ba:function ba(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
hx:function hx(a){this.a=a},
hy:function hy(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
aB:function aB(a,b){this.a=a
this.$ti=b},
ei:function ei(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
bK:function bK(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null},
cH:function cH(a,b){this.a=a
this.$ti=b},
eh:function eh(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
kw:function kw(a){this.a=a},
kx:function kx(a){this.a=a},
ky:function ky(a){this.a=a},
dq:function dq(){},
eT:function eT(){},
qu(a){throw A.L(A.lH(a),new Error())},
M(){throw A.L(A.nS(""),new Error())},
mK(){throw A.L(A.nR(""),new Error())},
qv(){throw A.L(A.lH(""),new Error())},
ol(){var s=new A.iH("")
return s.b=s},
iH:function iH(a){this.a=a
this.b=null},
p2(a){return a},
f5(a,b,c){},
lI(a,b,c){var s
A.f5(a,b,c)
s=new DataView(a,b)
return s},
aE(a,b,c){A.f5(a,b,c)
c=B.b.U(a.byteLength-b,4)
return new Int32Array(a,b,c)},
nY(a,b,c){A.f5(a,b,c)
return new Uint32Array(a,b,c)},
nZ(a){return new Uint8Array(a)},
ag(a,b,c){A.f5(a,b,c)
return c==null?new Uint8Array(a,b):new Uint8Array(a,b,c)},
aK(a,b,c){if(a>>>0!==a||a>=c)throw A.b(A.lg(b,a))},
p3(a,b,c){var s
if(!(a>>>0!==a))s=b>>>0!==b||a>b||b>c
else s=!0
if(s)throw A.b(A.q9(a,b,c))
return b},
bN:function bN(){},
bM:function bM(){},
cP:function cP(){},
f1:function f1(a){this.a=a},
cN:function cN(){},
bO:function bO(){},
cO:function cO(){},
ab:function ab(){},
el:function el(){},
em:function em(){},
en:function en(){},
eo:function eo(){},
ep:function ep(){},
eq:function eq(){},
er:function er(){},
cQ:function cQ(){},
bf:function bf(){},
dk:function dk(){},
dl:function dl(){},
dm:function dm(){},
dn:function dn(){},
kW(a,b){var s=b.c
return s==null?b.c=A.dz(a,"w",[b.x]):s},
lT(a){var s=a.w
if(s===6||s===7)return A.lT(a.x)
return s===11||s===12},
o6(a){return a.as},
ap(a){return A.jX(v.typeUniverse,a,!1)},
bz(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.bz(a1,s,a3,a4)
if(r===s)return a2
return A.ma(a1,r,!0)
case 7:s=a2.x
r=A.bz(a1,s,a3,a4)
if(r===s)return a2
return A.m9(a1,r,!0)
case 8:q=a2.y
p=A.ci(a1,q,a3,a4)
if(p===q)return a2
return A.dz(a1,a2.x,p)
case 9:o=a2.x
n=A.bz(a1,o,a3,a4)
m=a2.y
l=A.ci(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.l4(a1,n,l)
case 10:k=a2.x
j=a2.y
i=A.ci(a1,j,a3,a4)
if(i===j)return a2
return A.mb(a1,k,i)
case 11:h=a2.x
g=A.bz(a1,h,a3,a4)
f=a2.y
e=A.pJ(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.m8(a1,g,e)
case 12:d=a2.y
a4+=d.length
c=A.ci(a1,d,a3,a4)
o=a2.x
n=A.bz(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.l5(a1,n,c,!0)
case 13:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.b(A.dO("Attempted to substitute unexpected RTI kind "+a0))}},
ci(a,b,c,d){var s,r,q,p,o=b.length,n=A.k0(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.bz(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
pK(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.k0(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.bz(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
pJ(a,b,c,d){var s,r=b.a,q=A.ci(a,r,c,d),p=b.b,o=A.ci(a,p,c,d),n=b.c,m=A.pK(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.eL()
s.a=q
s.b=o
s.c=m
return s},
v(a,b){a[v.arrayRti]=b
return a},
mz(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.qf(s)
return a.$S()}return null},
qj(a,b){var s
if(A.lT(b))if(a instanceof A.b7){s=A.mz(a)
if(s!=null)return s}return A.bE(a)},
bE(a){if(a instanceof A.d)return A.A(a)
if(Array.isArray(a))return A.aw(a)
return A.l7(J.bC(a))},
aw(a){var s=a[v.arrayRti],r=t.gn
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
A(a){var s=a.$ti
return s!=null?s:A.l7(a)},
l7(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.pc(a,s)},
pc(a,b){var s=a instanceof A.b7?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.oJ(v.typeUniverse,s.name)
b.$ccache=r
return r},
qf(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.jX(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
qe(a){return A.bB(A.A(a))},
ld(a){var s
if(a instanceof A.dq)return A.qb(a.$r,a.de())
s=a instanceof A.b7?A.mz(a):null
if(s!=null)return s
if(t.dm.b(a))return J.nb(a).a
if(Array.isArray(a))return A.aw(a)
return A.bE(a)},
bB(a){var s=a.r
return s==null?a.r=new A.jW(a):s},
qb(a,b){var s,r,q=b,p=q.length
if(p===0)return t.bQ
s=A.dB(v.typeUniverse,A.ld(q[0]),"@<0>")
for(r=1;r<p;++r)s=A.md(v.typeUniverse,s,A.ld(q[r]))
return A.dB(v.typeUniverse,s,a)},
aq(a){return A.bB(A.jX(v.typeUniverse,a,!1))},
pb(a){var s=this
s.b=A.pH(s)
return s.b(a)},
pH(a){var s,r,q,p
if(a===t.K)return A.pk
if(A.bF(a))return A.po
s=a.w
if(s===6)return A.p9
if(s===1)return A.mo
if(s===7)return A.pf
r=A.pG(a)
if(r!=null)return r
if(s===8){q=a.x
if(a.y.every(A.bF)){a.f="$i"+q
if(q==="r")return A.pi
if(a===t.m)return A.ph
return A.pn}}else if(s===10){p=A.q8(a.x,a.y)
return p==null?A.mo:p}return A.p7},
pG(a){if(a.w===8){if(a===t.S)return A.la
if(a===t.i||a===t.o)return A.pj
if(a===t.N)return A.pm
if(a===t.y)return A.kj}return null},
pa(a){var s=this,r=A.p6
if(A.bF(s))r=A.oU
else if(s===t.K)r=A.oS
else if(A.cl(s)){r=A.p8
if(s===t.I)r=A.oP
else if(s===t.dk)r=A.oT
else if(s===t.a6)r=A.oO
else if(s===t.cg)r=A.oR
else if(s===t.cD)r=A.mh
else if(s===t.A)r=A.mi}else if(s===t.S)r=A.Y
else if(s===t.N)r=A.dE
else if(s===t.y)r=A.bx
else if(s===t.o)r=A.oQ
else if(s===t.i)r=A.by
else if(s===t.m)r=A.Z
s.a=r
return s.a(a)},
p7(a){var s=this
if(a==null)return A.cl(s)
return A.ql(v.typeUniverse,A.qj(a,s),s)},
p9(a){if(a==null)return!0
return this.x.b(a)},
pn(a){var s,r=this
if(a==null)return A.cl(r)
s=r.f
if(a instanceof A.d)return!!a[s]
return!!J.bC(a)[s]},
pi(a){var s,r=this
if(a==null)return A.cl(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.d)return!!a[s]
return!!J.bC(a)[s]},
ph(a){var s=this
if(a==null)return!1
if(typeof a=="object"){if(a instanceof A.d)return!!a[s.f]
return!0}if(typeof a=="function")return!0
return!1},
mn(a){if(typeof a=="object"){if(a instanceof A.d)return t.m.b(a)
return!0}if(typeof a=="function")return!0
return!1},
p6(a){var s=this
if(a==null){if(A.cl(s))return a}else if(s.b(a))return a
throw A.L(A.mj(a,s),new Error())},
p8(a){var s=this
if(a==null||s.b(a))return a
throw A.L(A.mj(a,s),new Error())},
mj(a,b){return new A.dx("TypeError: "+A.m3(a,A.ae(b,null)))},
m3(a,b){return A.hf(a)+": type '"+A.ae(A.ld(a),null)+"' is not a subtype of type '"+b+"'"},
aj(a,b){return new A.dx("TypeError: "+A.m3(a,b))},
pf(a){var s=this
return s.x.b(a)||A.kW(v.typeUniverse,s).b(a)},
pk(a){return a!=null},
oS(a){if(a!=null)return a
throw A.L(A.aj(a,"Object"),new Error())},
po(a){return!0},
oU(a){return a},
mo(a){return!1},
kj(a){return!0===a||!1===a},
bx(a){if(!0===a)return!0
if(!1===a)return!1
throw A.L(A.aj(a,"bool"),new Error())},
oO(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.L(A.aj(a,"bool?"),new Error())},
by(a){if(typeof a=="number")return a
throw A.L(A.aj(a,"double"),new Error())},
mh(a){if(typeof a=="number")return a
if(a==null)return a
throw A.L(A.aj(a,"double?"),new Error())},
la(a){return typeof a=="number"&&Math.floor(a)===a},
Y(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.L(A.aj(a,"int"),new Error())},
oP(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.L(A.aj(a,"int?"),new Error())},
pj(a){return typeof a=="number"},
oQ(a){if(typeof a=="number")return a
throw A.L(A.aj(a,"num"),new Error())},
oR(a){if(typeof a=="number")return a
if(a==null)return a
throw A.L(A.aj(a,"num?"),new Error())},
pm(a){return typeof a=="string"},
dE(a){if(typeof a=="string")return a
throw A.L(A.aj(a,"String"),new Error())},
oT(a){if(typeof a=="string")return a
if(a==null)return a
throw A.L(A.aj(a,"String?"),new Error())},
Z(a){if(A.mn(a))return a
throw A.L(A.aj(a,"JSObject"),new Error())},
mi(a){if(a==null)return a
if(A.mn(a))return a
throw A.L(A.aj(a,"JSObject?"),new Error())},
mt(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.ae(a[q],b)
return s},
px(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.mt(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.ae(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
ml(a1,a2,a3){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=", ",a0=null
if(a3!=null){s=a3.length
if(a2==null)a2=A.v([],t.s)
else a0=a2.length
r=a2.length
for(q=s;q>0;--q)a2.push("T"+(r+q))
for(p=t.X,o="<",n="",q=0;q<s;++q,n=a){o=o+n+a2[a2.length-1-q]
m=a3[q]
l=m.w
if(!(l===2||l===3||l===4||l===5||m===p))o+=" extends "+A.ae(m,a2)}o+=">"}else o=""
p=a1.x
k=a1.y
j=k.a
i=j.length
h=k.b
g=h.length
f=k.c
e=f.length
d=A.ae(p,a2)
for(c="",b="",q=0;q<i;++q,b=a)c+=b+A.ae(j[q],a2)
if(g>0){c+=b+"["
for(b="",q=0;q<g;++q,b=a)c+=b+A.ae(h[q],a2)
c+="]"}if(e>0){c+=b+"{"
for(b="",q=0;q<e;q+=3,b=a){c+=b
if(f[q+1])c+="required "
c+=A.ae(f[q+2],a2)+" "+f[q]}c+="}"}if(a0!=null){a2.toString
a2.length=a0}return o+"("+c+") => "+d},
ae(a,b){var s,r,q,p,o,n,m=a.w
if(m===5)return"erased"
if(m===2)return"dynamic"
if(m===3)return"void"
if(m===1)return"Never"
if(m===4)return"any"
if(m===6){s=a.x
r=A.ae(s,b)
q=s.w
return(q===11||q===12?"("+r+")":r)+"?"}if(m===7)return"FutureOr<"+A.ae(a.x,b)+">"
if(m===8){p=A.pM(a.x)
o=a.y
return o.length>0?p+("<"+A.mt(o,b)+">"):p}if(m===10)return A.px(a,b)
if(m===11)return A.ml(a,b,null)
if(m===12)return A.ml(a.x,b,a.y)
if(m===13){n=a.x
return b[b.length-1-n]}return"?"},
pM(a){var s=A.mL(a)
if(s!=null)return s
return"minified:"+a},
oK(a,b){var s=a.tR[b]
while(typeof s=="string")s=a.tR[s]
return s},
oJ(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.jX(a,b,!1)
else if(typeof m=="number"){s=m
r=A.dA(a,5,"#")
q=A.k0(s)
for(p=0;p<s;++p)q[p]=r
o=A.dz(a,b,q)
n[b]=o
return o}else return m},
oI(a,b){return A.mf(a.tR,b)},
oH(a,b){return A.mf(a.eT,b)},
jX(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.mc(a,null,b,!1)
r.set(b,s)
return s},
dB(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.mc(a,b,c,!0)
q.set(c,r)
return r},
md(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.l4(a,b,c.w===9?c.y:[c])
p.set(s,q)
return q},
mc(a,b,c,d){return A.oy(A.os(a,b,c,d))},
b_(a,b){b.a=A.pa
b.b=A.pb
return b},
dA(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.am(null,null)
s.w=b
s.as=c
r=A.b_(a,s)
a.eC.set(c,r)
return r},
ma(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.oF(a,b,r,c)
a.eC.set(r,s)
return s},
oF(a,b,c,d){var s,r,q
if(d){s=b.w
r=!0
if(!A.bF(b))if(!(b===t.P||b===t.T))if(s!==6)r=s===7&&A.cl(b.x)
if(r)return b
else if(s===1)return t.P}q=new A.am(null,null)
q.w=6
q.x=b
q.as=c
return A.b_(a,q)},
m9(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.oD(a,b,r,c)
a.eC.set(r,s)
return s},
oD(a,b,c,d){var s,r
if(d){s=b.w
if(A.bF(b)||b===t.K)return b
else if(s===1)return A.dz(a,"w",[b])
else if(b===t.P||b===t.T)return t.eH}r=new A.am(null,null)
r.w=7
r.x=b
r.as=c
return A.b_(a,r)},
oG(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.am(null,null)
s.w=13
s.x=b
s.as=q
r=A.b_(a,s)
a.eC.set(q,r)
return r},
dy(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
oC(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
dz(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.dy(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.am(null,null)
r.w=8
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.b_(a,r)
a.eC.set(p,q)
return q},
l4(a,b,c){var s,r,q,p,o,n
if(b.w===9){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.dy(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.am(null,null)
o.w=9
o.x=s
o.y=r
o.as=q
n=A.b_(a,o)
a.eC.set(q,n)
return n},
mb(a,b,c){var s,r,q="+"+(b+"("+A.dy(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.am(null,null)
s.w=10
s.x=b
s.y=c
s.as=q
r=A.b_(a,s)
a.eC.set(q,r)
return r},
m8(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.dy(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.dy(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.oC(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.am(null,null)
p.w=11
p.x=b
p.y=c
p.as=r
o=A.b_(a,p)
a.eC.set(r,o)
return o},
l5(a,b,c,d){var s,r=b.as+("<"+A.dy(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.oE(a,b,c,r,d)
a.eC.set(r,s)
return s},
oE(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.k0(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.bz(a,b,r,0)
m=A.ci(a,c,r,0)
return A.l5(a,n,m,c!==m)}}l=new A.am(null,null)
l.w=12
l.x=b
l.y=c
l.as=d
return A.b_(a,l)},
os(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
oy(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.ou(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.m5(a,r,l,k,!1)
else if(q===46)r=A.m5(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.bt(a.u,a.e,k.pop()))
break
case 94:k.push(A.oG(a.u,k.pop()))
break
case 35:k.push(A.dA(a.u,5,"#"))
break
case 64:k.push(A.dA(a.u,2,"@"))
break
case 126:k.push(A.dA(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.ow(a,k)
break
case 38:A.ov(a,k)
break
case 63:p=a.u
k.push(A.ma(p,A.bt(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.m9(p,A.bt(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.ot(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.m6(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.oz(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-2)
break
case 43:n=l.indexOf("(",r)
k.push(l.substring(r,n))
k.push(-4)
k.push(a.p)
a.p=k.length
r=n+1
break
default:throw"Bad character "+q}}}m=k.pop()
return A.bt(a.u,a.e,m)},
ou(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
m5(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===9)o=o.x
n=A.oK(s,o.x)[p]
if(n==null)A.y('No "'+p+'" in "'+A.o6(o)+'"')
d.push(A.dB(s,o,n))}else d.push(p)
return m},
ow(a,b){var s,r=a.u,q=A.m4(a,b),p=b.pop()
if(typeof p=="string")b.push(A.dz(r,p,q))
else{s=A.bt(r,a.e,p)
switch(s.w){case 11:b.push(A.l5(r,s,q,a.n))
break
default:b.push(A.l4(r,s,q))
break}}},
ot(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.m4(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.bt(p,a.e,o)
q=new A.eL()
q.a=s
q.b=n
q.c=m
b.push(A.m8(p,r,q))
return
case-4:b.push(A.mb(p,b.pop(),s))
return
default:throw A.b(A.dO("Unexpected state under `()`: "+A.u(o)))}},
ov(a,b){var s=b.pop()
if(0===s){b.push(A.dA(a.u,1,"0&"))
return}if(1===s){b.push(A.dA(a.u,4,"1&"))
return}throw A.b(A.dO("Unexpected extended operation "+A.u(s)))},
m4(a,b){var s=b.splice(a.p)
A.m6(a.u,a.e,s)
a.p=b.pop()
return s},
bt(a,b,c){if(typeof c=="string")return A.dz(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.ox(a,b,c)}else return c},
m6(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.bt(a,b,c[s])},
oz(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.bt(a,b,c[s])},
ox(a,b,c){var s,r,q=b.w
if(q===9){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==8)throw A.b(A.dO("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.b(A.dO("Bad index "+c+" for "+b.i(0)))},
ql(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.P(a,b,null,c,null)
r.set(c,s)}return s},
P(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(A.bF(d))return!0
s=b.w
if(s===4)return!0
if(A.bF(b))return!1
if(b.w===1)return!0
r=s===13
if(r)if(A.P(a,c[b.x],c,d,e))return!0
q=d.w
p=t.P
if(b===p||b===t.T){if(q===7)return A.P(a,b,c,d.x,e)
return d===p||d===t.T||q===6}if(d===t.K){if(s===7)return A.P(a,b.x,c,d,e)
return s!==6}if(s===7){if(!A.P(a,b.x,c,d,e))return!1
return A.P(a,A.kW(a,b),c,d,e)}if(s===6)return A.P(a,p,c,d,e)&&A.P(a,b.x,c,d,e)
if(q===7){if(A.P(a,b,c,d.x,e))return!0
return A.P(a,b,c,A.kW(a,d),e)}if(q===6)return A.P(a,b,c,p,e)||A.P(a,b,c,d.x,e)
if(r)return!1
p=s!==11
if((!p||s===12)&&d===t.b8)return!0
o=s===10
if(o&&d===t.gT)return!0
if(q===12){if(b===t.g)return!0
if(s!==12)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.P(a,j,c,i,e)||!A.P(a,i,e,j,c))return!1}return A.mm(a,b.x,c,d.x,e)}if(q===11){if(b===t.g)return!0
if(p)return!1
return A.mm(a,b,c,d,e)}if(s===8){if(q!==8)return!1
return A.pg(a,b,c,d,e)}if(o&&q===10)return A.pl(a,b,c,d,e)
return!1},
mm(a3,a4,a5,a6,a7){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.P(a3,a4.x,a5,a6.x,a7))return!1
s=a4.y
r=a6.y
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.P(a3,p[h],a7,g,a5))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.P(a3,p[o+h],a7,g,a5))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.P(a3,k[h],a7,g,a5))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.P(a3,e[a+2],a7,g,a5))return!1
break}}while(b<d){if(f[b+1])return!1
b+=3}return!0},
pg(a,b,c,d,e){var s,r,q,p,o,n=b.x,m=d.x
while(n!==m){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.dB(a,b,r[o])
return A.mg(a,p,null,c,d.y,e)}return A.mg(a,b.y,null,c,d.y,e)},
mg(a,b,c,d,e,f){var s,r=b.length
for(s=0;s<r;++s)if(!A.P(a,b[s],d,e[s],f))return!1
return!0},
pl(a,b,c,d,e){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.P(a,r[s],c,q[s],e))return!1
return!0},
cl(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.bF(a))if(s!==6)r=s===7&&A.cl(a.x)
return r},
bF(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
mf(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
k0(a){return a>0?new Array(a):v.typeUniverse.sEA},
am:function am(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
eL:function eL(){this.c=this.b=this.a=null},
jW:function jW(a){this.a=a},
eJ:function eJ(){},
dx:function dx(a){this.a=a},
oh(){var s,r,q
if(self.scheduleImmediate!=null)return A.pO()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.b1(new A.iC(s),1)).observe(r,{childList:true})
return new A.iB(s,r,q)}else if(self.setImmediate!=null)return A.pP()
return A.pQ()},
oi(a){self.scheduleImmediate(A.b1(new A.iD(a),0))},
oj(a){self.setImmediate(A.b1(new A.iE(a),0))},
ok(a){A.lZ(B.a_,a)},
lZ(a,b){var s=B.b.U(a.a,1000)
return A.oA(s<0?0:s,b)},
oA(a,b){var s=new A.f0()
s.ex(a,b)
return s},
oB(a,b){var s=new A.f0()
s.ey(a,b)
return s},
i(a){return new A.d7(new A.k($.l,a.h("k<0>")),a.h("d7<0>"))},
h(a,b){a.$2(0,null)
b.b=!0
return b.a},
c(a,b){A.oV(a,b)},
f(a,b){b.B(a)},
e(a,b){b.af(A.R(a),A.Q(a))},
oV(a,b){var s,r,q=new A.kd(b),p=new A.ke(b)
if(a instanceof A.k)a.dz(q,p,t.z)
else{s=t.z
if(a instanceof A.k)a.am(q,p,s)
else{r=new A.k($.l,t.eI)
r.a=8
r.c=a
r.dz(q,p,s)}}},
j(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.l.bb(new A.ko(s),t.H,t.S,t.z)},
m7(a,b,c){return 0},
cq(a){var s
if(t.C.b(a)){s=a.gaa()
if(s!=null)return s}return B.i},
e7(a,b){var s,r,q,p,o,n,m,l=null
try{l=a.$0()}catch(q){s=A.R(q)
r=A.Q(q)
p=new A.k($.l,b.h("k<0>"))
o=s
n=r
m=A.f6(o,n)
if(m==null)o=new A.H(o,n==null?A.cq(o):n)
else o=m
p.a3(o)
return p}return b.h("w<0>").b(l)?l:A.c8(l,b)},
hn(a,b){var s=a==null?b.a(a):a,r=new A.k($.l,b.h("k<0>"))
r.aT(s)
return r},
lC(a,b){var s,r,q,p,o,n,m,l,k,j,i={},h=null,g=!1,f=new A.k($.l,b.h("k<r<0>>"))
i.a=null
i.b=0
i.c=i.d=null
s=new A.hp(i,h,g,f)
try{for(n=J.ak(a),m=t.P;n.j();){r=n.gl()
q=i.b
r.am(new A.ho(i,q,f,b,h,g),s,m);++i.b}n=i.b
if(n===0){n=f
n.aU(A.v([],b.h("p<0>")))
return n}i.a=A.hz(n,null,!1,b.h("0?"))}catch(l){p=A.R(l)
o=A.Q(l)
if(i.b===0||g){n=f
m=p
k=o
j=A.f6(m,k)
if(j==null)m=new A.H(m,k==null?A.cq(m):k)
else m=j
n.a3(m)
return n}else{i.d=p
i.c=o}}return f},
kO(a,b,c,d){var s=new A.hi(d,null,b,c),r=$.l,q=new A.k(r,c.h("k<0>"))
if(r!==B.a)s=r.bb(s,c.h("0/"),t.K,t.l)
a.aS(new A.av(q,2,null,s,a.$ti.h("@<1>").M(c).h("av<1,2>")))
return q},
nE(a,b){var s,r,q,p=A.v([],b.h("p<df<0>>"))
for(s=a.length,r=b.h("df<0>"),q=0;q<a.length;a.length===s||(0,A.T)(a),++q)p.push(new A.df(a[q],r))
if(p.length===0)return A.hn(A.v([],b.h("p<0>")),b.h("r<0>"))
s=new A.k($.l,b.h("k<r<0>>"))
A.op(p,new A.hj(new A.D(s,b.h("D<r<0>>")),p,b))
return s},
pr(a){return a!=null},
op(a,b){var s,r={},q=r.a=r.b=0,p=new A.jd(r,a,b)
for(s=a.length;q<a.length;a.length===s||(0,A.T)(a),++q)a[q].fp(p)},
f6(a,b){var s,r,q,p=$.l
if(p===B.a)return null
s=p.dQ(a,b)
if(s==null)return null
r=s.a
q=s.b
if(t.C.b(r))A.ev(r,q)
return s},
l8(a,b){var s
if($.l!==B.a){s=A.f6(a,b)
if(s!=null)return s}if(b==null)if(t.C.b(a)){b=a.gaa()
if(b==null){A.ev(a,B.i)
b=B.i}}else b=B.i
else if(t.C.b(a))A.ev(a,b)
return new A.H(a,b)},
oo(a,b,c){var s=new A.k(b,c.h("k<0>"))
s.a=8
s.c=a
return s},
c8(a,b){var s=new A.k($.l,b.h("k<0>"))
s.a=8
s.c=a
return s},
jj(a,b,c){var s,r,q,p={},o=p.a=a
while(s=o.a,(s&4)!==0){o=o.c
p.a=o}if(o===b){s=A.lX()
b.a3(new A.H(new A.al(!0,o,null,"Cannot complete a future with itself"),s))
return}r=b.a&1
s=o.a=s|r
if((s&24)===0){q=b.c
b.a=b.a&1|4
b.c=o
o.dj(q)
return}if(!c)if(b.c==null)o=(s&16)===0||r!==0
else o=!1
else o=!0
if(o){q=b.aY()
b.bj(p.a)
A.br(b,q)
return}b.a^=2
b.b.a9(new A.jk(p,b))},
br(a,b){var s,r,q,p,o,n,m,l,k,j,i,h,g={},f=g.a=a
for(;;){s={}
r=f.a
q=(r&16)===0
p=!q
if(b==null){if(p&&(r&1)===0){r=f.c
f.b.aI(r.a,r.b)}return}s.a=b
o=b.a
for(f=b;o!=null;f=o,o=n){f.a=null
A.br(g.a,f)
s.a=o
n=o.a}r=g.a
m=r.c
s.b=p
s.c=m
if(q){l=f.c
l=(l&1)!==0||(l&15)===8}else l=!0
if(l){k=f.b.b
if(p){f=r.b
f=!(f===k||f.ga_()===k.ga_())}else f=!1
if(f){f=g.a
r=f.c
f.b.aI(r.a,r.b)
return}j=$.l
if(j!==k)$.l=k
else j=null
f=s.a.c
if((f&15)===8)new A.jo(s,g,p).$0()
else if(q){if((f&1)!==0)new A.jn(s,m).$0()}else if((f&2)!==0)new A.jm(g,s).$0()
if(j!=null)$.l=j
f=s.c
if(f instanceof A.k){r=s.a.$ti
r=r.h("w<2>").b(f)||!r.y[1].b(f)}else r=!1
if(r){i=s.a.b
if((f.a&24)!==0){h=i.c
i.c=null
b=i.bn(h)
i.a=f.a&30|i.a&1
i.c=f.c
g.a=f
continue}else A.jj(f,i,!0)
return}}i=s.a.b
h=i.c
i.c=null
b=i.bn(h)
f=s.b
r=s.c
if(!f){i.a=8
i.c=r}else{i.a=i.a&1|16
i.c=r}g.a=i
f=i}},
py(a,b){if(t.R.b(a))return b.bb(a,t.z,t.K,t.l)
if(t.E.b(a))return b.aK(a,t.z,t.K)
throw A.b(A.b4(a,"onError",u.c))},
pq(){var s,r
for(s=$.ch;s!=null;s=$.ch){$.dG=null
r=s.b
$.ch=r
if(r==null)$.dF=null
s.a.$0()}},
pI(){$.l9=!0
try{A.pq()}finally{$.dG=null
$.l9=!1
if($.ch!=null)$.ll().$1(A.mx())}},
mu(a){var s=new A.eD(a),r=$.dF
if(r==null){$.ch=$.dF=s
if(!$.l9)$.ll().$1(A.mx())}else $.dF=r.b=s},
pF(a){var s,r,q,p=$.ch
if(p==null){A.mu(a)
$.dG=$.dF
return}s=new A.eD(a)
r=$.dG
if(r==null){s.b=p
$.ch=$.dG=s}else{q=r.b
s.b=q
$.dG=r.b=s
if(q==null)$.dF=s}},
qt(a){var s,r=null,q=$.l
if(B.a===q){A.kn(r,r,B.a,a)
return}if(B.a===q.gcg().a)s=B.a.ga_()===q.ga_()
else s=!1
if(s){A.kn(r,r,q,q.ak(a,t.H))
return}s=$.l
s.a9(s.bo(a))},
qK(a){return new A.bv(A.dJ(a,"stream",t.K))},
lc(a){var s,r,q
if(a==null)return
try{a.$0()}catch(q){s=A.R(q)
r=A.Q(q)
$.l.aI(s,r)}},
l2(a,b,c){var s=b==null?A.pS():b
return a.aK(s,t.H,c)},
m1(a,b){if(b==null)b=A.pU()
if(t.da.b(b))return a.bb(b,t.z,t.K,t.l)
if(t.d5.b(b))return a.aK(b,t.z,t.K)
throw A.b(A.a0("handleError callback must take either an Object (the error), or both an Object (the error) and a StackTrace.",null))},
ps(a){},
pu(a,b){$.l.aI(a,b)},
pt(){},
p1(a,b,c){var s=a.p()
if(s!==$.cn())s.J(new A.kf(b,c))
else b.aw(c)},
qs(a,b,c){return A.pE(a,null,b,c)},
pE(a,b,c,d){return $.l.dV(c,b).al(a,d)},
pC(a,b,c,d,e){A.dH(d,e)},
dH(a,b){A.pF(new A.kk(a,b))},
kl(a,b,c,d){var s,r=$.l
if(r===c)return d.$0()
$.l=c
s=r
try{r=d.$0()
return r}finally{$.l=s}},
km(a,b,c,d,e){var s,r=$.l
if(r===c)return d.$1(e)
$.l=c
s=r
try{r=d.$1(e)
return r}finally{$.l=s}},
lb(a,b,c,d,e,f){var s,r=$.l
if(r===c)return d.$2(e,f)
$.l=c
s=r
try{r=d.$2(e,f)
return r}finally{$.l=s}},
mr(a,b,c,d){return d},
ms(a,b,c,d){return d},
mq(a,b,c,d){return d},
pB(a,b,c,d,e){return null},
kn(a,b,c,d){var s,r
if(B.a!==c){s=B.a.ga_()
r=c.ga_()
d=s!==r?c.bo(d):c.co(d,t.H)}A.mu(d)},
pA(a,b,c,d,e){e=c.co(e,t.H)
return A.lZ(d,e)},
pz(a,b,c,d,e){var s
e=c.iE(e,t.H,t.aF)
s=d.giJ()
return A.oB(s.iC(0,0)?0:s,e)},
pD(a,b,c,d){A.mH(d)},
mp(a,b,c,d,e){var s,r=new A.eF(c.gdr(),c.gdt(),c.gds(),c.gdm(),c.gdn(),c.gdl(),c.gd8(),c.gcg(),c.gd4(),c.gd3(),c.gdk(),c.gda(),c.gc6(),c.gdD(),c),q=d.x
if(q!=null)r.w=new A.f4(r,q)
s=d.a
if(s!=null)r.as=new A.f3(r,s)
return r},
iC:function iC(a){this.a=a},
iB:function iB(a,b,c){this.a=a
this.b=b
this.c=c},
iD:function iD(a){this.a=a},
iE:function iE(a){this.a=a},
f0:function f0(){this.c=0},
jV:function jV(a,b){this.a=a
this.b=b},
jU:function jU(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
d7:function d7(a,b){this.a=a
this.b=!1
this.$ti=b},
kd:function kd(a){this.a=a},
ke:function ke(a){this.a=a},
ko:function ko(a){this.a=a},
eZ:function eZ(a){var _=this
_.a=a
_.e=_.d=_.c=_.b=null},
cb:function cb(a,b){this.a=a
this.$ti=b},
H:function H(a,b){this.a=a
this.b=b},
hp:function hp(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
ho:function ho(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
hi:function hi(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
hj:function hj(a,b,c){this.a=a
this.b=b
this.c=c},
cS:function cS(a,b){this.c=a
this.d=b},
df:function df(a,b){var _=this
_.a=a
_.c=_.b=null
_.$ti=b},
je:function je(a,b){this.a=a
this.b=b},
jf:function jf(a,b){this.a=a
this.b=b},
jd:function jd(a,b,c){this.a=a
this.b=b
this.c=c},
c0:function c0(){},
au:function au(a,b){this.a=a
this.$ti=b},
D:function D(a,b){this.a=a
this.$ti=b},
av:function av(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
k:function k(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
jg:function jg(a,b){this.a=a
this.b=b},
jl:function jl(a,b){this.a=a
this.b=b},
jk:function jk(a,b){this.a=a
this.b=b},
ji:function ji(a,b){this.a=a
this.b=b},
jh:function jh(a,b){this.a=a
this.b=b},
jo:function jo(a,b,c){this.a=a
this.b=b
this.c=c},
jp:function jp(a,b){this.a=a
this.b=b},
jq:function jq(a){this.a=a},
jn:function jn(a,b){this.a=a
this.b=b},
jm:function jm(a,b){this.a=a
this.b=b},
eD:function eD(a){this.a=a
this.b=null},
O:function O(){},
i_:function i_(a,b){this.a=a
this.b=b},
i0:function i0(a,b){this.a=a
this.b=b},
hY:function hY(a){this.a=a},
hZ:function hZ(a,b,c){this.a=a
this.b=b
this.c=c},
bu:function bu(){},
jQ:function jQ(a){this.a=a},
jP:function jP(a){this.a=a},
f_:function f_(){},
eE:function eE(){},
bZ:function bZ(){},
cc:function cc(a,b,c,d,e){var _=this
_.a=null
_.b=0
_.c=null
_.d=a
_.e=b
_.f=c
_.r=d
_.$ti=e},
c3:function c3(a,b){this.a=a
this.$ti=b},
c4:function c4(a,b,c,d,e,f,g){var _=this
_.w=a
_.a=b
_.b=c
_.c=d
_.d=e
_.e=f
_.r=_.f=null
_.$ti=g},
ad:function ad(){},
iG:function iG(a,b,c){this.a=a
this.b=b
this.c=c},
iF:function iF(a){this.a=a},
dv:function dv(){},
eI:function eI(){},
aY:function aY(a){this.b=a
this.a=null},
d9:function d9(a,b){this.b=a
this.c=b
this.a=null},
j5:function j5(){},
dp:function dp(){this.a=0
this.c=this.b=null},
jE:function jE(a,b){this.a=a
this.b=b},
bv:function bv(a){this.a=null
this.b=a
this.c=!1},
aI:function aI(a,b){this.b=a
this.$ti=b},
jC:function jC(a,b){this.a=a
this.b=b},
dj:function dj(a,b,c,d,e){var _=this
_.a=null
_.b=0
_.c=null
_.d=a
_.e=b
_.f=c
_.r=d
_.$ti=e},
kf:function kf(a,b){this.a=a
this.b=b},
dd:function dd(){},
c7:function c7(a,b,c,d,e,f,g){var _=this
_.w=a
_.x=null
_.a=b
_.b=c
_.c=d
_.d=e
_.e=f
_.r=_.f=null
_.$ti=g},
bs:function bs(a,b,c){this.b=a
this.a=b
this.$ti=c},
k9:function k9(a,b){this.a=a
this.b=b},
kb:function kb(a,b){this.a=a
this.b=b},
ka:function ka(a,b){this.a=a
this.b=b},
k7:function k7(a,b){this.a=a
this.b=b},
k8:function k8(a,b){this.a=a
this.b=b},
k6:function k6(a,b){this.a=a
this.b=b},
k3:function k3(a,b){this.a=a
this.b=b},
f4:function f4(a,b){this.a=a
this.b=b},
k2:function k2(){},
k1:function k1(){},
k5:function k5(a,b){this.a=a
this.b=b},
k4:function k4(a,b){this.a=a
this.b=b},
f3:function f3(a,b){this.a=a
this.b=b},
kc:function kc(){},
f2:function f2(){},
eF:function eF(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=i
_.y=j
_.z=k
_.Q=l
_.as=m
_.at=n
_.ax=null
_.ay=o},
j2:function j2(a,b,c){this.a=a
this.b=b
this.c=c},
j1:function j1(a,b){this.a=a
this.b=b},
j3:function j3(a,b,c){this.a=a
this.b=b
this.c=c},
eV:function eV(){},
jI:function jI(a,b,c){this.a=a
this.b=b
this.c=c},
jH:function jH(a,b){this.a=a
this.b=b},
jJ:function jJ(a,b,c){this.a=a
this.b=b
this.c=c},
cf:function cf(a){this.a=a},
kk:function kk(a,b){this.a=a
this.b=b},
d6:function d6(a,b,c,d,e,f,g,h,i,j,k,l,m){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.x=i
_.y=j
_.z=k
_.Q=l
_.as=m},
nT(a,b){return new A.ba(a.h("@<0>").M(b).h("ba<1,2>"))},
aC(a,b){return new A.ba(a.h("@<0>").M(b).h("ba<1,2>"))},
cI(a){return new A.di(a.h("di<0>"))},
l3(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
or(a,b,c){var s=new A.c9(a,b,c.h("c9<0>"))
s.c=a.e
return s},
kU(a){var s,r
if(A.li(a))return"{...}"
s=new A.cZ("")
try{r={}
$.bA.push(a)
s.a+="{"
r.a=!0
a.bv(0,new A.hB(r,s))
s.a+="}"}finally{$.bA.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
kT(a){return new A.cJ(A.hz(A.nU(null),null,!1,a.h("0?")),a.h("cJ<0>"))},
nU(a){return 8},
di:function di(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
jB:function jB(a){this.a=a
this.c=this.b=null},
c9:function c9(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
bc:function bc(a){var _=this
_.b=_.a=0
_.c=null
_.$ti=a},
eQ:function eQ(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=null
_.d=c
_.e=!1
_.$ti=d},
X:function X(){},
t:function t(){},
cL:function cL(){},
hA:function hA(a){this.a=a},
hB:function hB(a,b){this.a=a
this.b=b},
cJ:function cJ(a,b){var _=this
_.a=a
_.d=_.c=_.b=0
_.$ti=b},
eR:function eR(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=null
_.$ti=e},
bR:function bR(){},
dt:function dt(){},
oM(a,b,c){var s,r,q,p=c-b
if(p<=4096)s=$.n2()
else s=new Uint8Array(p)
for(r=0;r<p;++r){q=a[b+r]
if((q&255)!==q)q=255
s[r]=q}return s},
oL(a,b,c,d){var s=a?$.n1():$.n0()
if(s==null)return null
if(0===c&&d===b.length)return A.me(s,b)
return A.me(s,b.subarray(c,d))},
me(a,b){var s,r
try{s=a.decode(b)
return s}catch(r){}return null},
oN(a){switch(a){case 65:return"Missing extension byte"
case 67:return"Unexpected extension byte"
case 69:return"Invalid UTF-8 byte"
case 71:return"Overlong encoding"
case 73:return"Out of unicode range"
case 75:return"Encoded surrogate"
case 77:return"Unfinished UTF-8 octet sequence"
default:return""}},
jZ:function jZ(){},
jY:function jY(){},
dV:function dV(){},
dX:function dX(){},
hd:function hd(){},
ie:function ie(){},
ig:function ig(){},
k_:function k_(a){this.b=0
this.c=a},
cd:function cd(a){this.a=a
this.b=16
this.c=0},
lz(a){},
jc(a,b){var s=$.n_()
s=s==null?null:new s(A.b1(A.qy(a,b),1))
return new A.eK(s,b.h("eK<0>"))},
nw(a,b){a=A.L(a,new Error())
a.stack=b.i(0)
throw a},
hz(a,b,c,d){var s,r=J.lG(a,d)
if(a!==0&&b!=null)for(s=0;s<a;++s)r[s]=b
return r},
nW(a,b,c){var s,r,q=A.v([],c.h("p<0>"))
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.T)(a),++r)q.push(a[r])
q.$flags=1
return q},
cK(a,b){var s,r=A.v([],b.h("p<0>"))
for(s=J.ak(a);s.j();)r.push(s.gl())
return r},
o8(a,b,c){var s,r
A.ah(b,"start")
s=c-b
if(s<0)throw A.b(A.ac(c,b,null,"end",null))
if(s===0)return""
r=A.o9(a,b,c)
return r},
o9(a,b,c){var s=a.length
if(b>=s)return""
return A.o2(a,b,c==null||c>s?s:c)},
lY(a,b,c){var s=J.ak(b)
if(!s.j())return a
if(c.length===0){do a+=A.u(s.gl())
while(s.j())}else{a+=A.u(s.gl())
while(s.j())a=a+c+A.u(s.gl())}return a},
lX(){return A.Q(new Error())},
ns(a){var s=Math.abs(a),r=a<0?"-":""
if(s>=1000)return""+a
if(s>=100)return r+"0"+s
if(s>=10)return r+"00"+s
return r+"000"+s},
lx(a){if(a>=100)return""+a
if(a>=10)return"0"+a
return"00"+a},
e2(a){if(a>=10)return""+a
return"0"+a},
ly(a,b){var s,r,q
for(s=a.length,r=0;r<s;++r){q=a[r]
if(q.b===b)return q}throw A.b(A.b4(b,"name","No enum value with that name"))},
hf(a){if(typeof a=="number"||A.kj(a)||a==null)return J.aL(a)
if(typeof a=="string")return JSON.stringify(a)
return A.lR(a)},
nx(a,b){A.dJ(a,"error",t.K)
A.dJ(b,"stackTrace",t.l)
A.nw(a,b)},
dO(a){return new A.dN(a)},
a0(a,b){return new A.al(!1,null,b,a)},
b4(a,b,c){return new A.al(!0,a,b,c)},
f9(a,b){return a},
lS(a){var s=null
return new A.bP(s,s,!1,s,s,a)},
ac(a,b,c,d,e){return new A.bP(b,c,!0,a,d,"Invalid value")},
bQ(a,b,c){if(0>a||a>c)throw A.b(A.ac(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.b(A.ac(b,a,c,"end",null))
return b}return c},
ah(a,b){if(a<0)throw A.b(A.ac(a,0,null,b,null))
return a},
lE(a,b){var s=b.b
return new A.cD(s,!0,a,null,"Index out of range")},
e9(a,b,c,d,e){return new A.cD(b,!0,a,e,"Index out of range")},
bk(a){return new A.d1(a)},
l_(a){return new A.eB(a)},
x(a){return new A.as(a)},
a5(a){return new A.dW(a)},
ny(a){return new A.j9(a)},
nD(a,b,c){return new A.hh(a,b,c)},
nJ(a,b,c){var s,r
if(A.li(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.v([],t.s)
$.bA.push(a)
try{A.pp(a,s)}finally{$.bA.pop()}r=A.lY(b,s,", ")+c
return r.charCodeAt(0)==0?r:r},
hv(a,b,c){var s,r
if(A.li(a))return b+"..."+c
s=new A.cZ(b)
$.bA.push(a)
try{r=s
r.a=A.lY(r.a,a,", ")}finally{$.bA.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
pp(a,b){var s,r,q,p,o,n,m,l=a.gt(a),k=0,j=0
for(;;){if(!(k<80||j<3))break
if(!l.j())return
s=A.u(l.gl())
b.push(s)
k+=s.length+2;++j}if(!l.j()){if(j<=5)return
r=b.pop()
q=b.pop()}else{p=l.gl();++j
if(!l.j()){if(j<=4){b.push(A.u(p))
return}r=A.u(p)
q=b.pop()
k+=r.length+2}else{o=l.gl();++j
for(;l.j();p=o,o=n){n=l.gl();++j
if(j>100){for(;;){if(!(k>75&&j>3))break
k-=b.pop().length+2;--j}b.push("...")
return}}q=A.u(p)
r=A.u(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
for(;;){if(!(k>80&&b.length>3))break
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)b.push(m)
b.push(q)
b.push(r)},
kV(a,b,c,d){var s
if(B.f===c){s=J.a8(a)
b=J.a8(b)
return A.kZ(A.aV(A.aV($.kK(),s),b))}if(B.f===d){s=J.a8(a)
b=J.a8(b)
c=J.a8(c)
return A.kZ(A.aV(A.aV(A.aV($.kK(),s),b),c))}s=J.a8(a)
b=J.a8(b)
c=J.a8(c)
d=J.a8(d)
d=A.kZ(A.aV(A.aV(A.aV(A.aV($.kK(),s),b),c),d))
return d},
eK:function eK(a,b){this.a=a
this.$ti=b},
e1:function e1(a,b,c){this.a=a
this.b=b
this.c=c},
az:function az(a){this.a=a},
j6:function j6(){},
F:function F(){},
dN:function dN(a){this.a=a},
aG:function aG(){},
al:function al(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
bP:function bP(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
cD:function cD(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
d1:function d1(a){this.a=a},
eB:function eB(a){this.a=a},
as:function as(a){this.a=a},
dW:function dW(a){this.a=a},
es:function es(){},
cY:function cY(){},
j9:function j9(a){this.a=a},
hh:function hh(a,b,c){this.a=a
this.b=b
this.c=c},
q:function q(){},
a6:function a6(a,b,c){this.a=a
this.b=b
this.$ti=c},
z:function z(){},
d:function d(){},
eY:function eY(){},
cZ:function cZ(a){this.a=a},
e4:function e4(a){this.a=a},
nV(a){return a},
nN(a){return a},
nP(a){return a},
kY(a){return a},
nK(a,b){var s,r,q,p,o
if(b.length===0)return!1
s=b.split(".")
r=v.G
for(q=s.length,p=0;p<q;++p,r=o){o=r[s[p]]
A.mi(o)
if(o==null)return!1}return a instanceof t.g.a(r)},
nF(a){return new v.G.Promise(A.a7(new A.hm(a)))},
hF:function hF(a){this.a=a},
hm:function hm(a){this.a=a},
hk:function hk(a){this.a=a},
hl:function hl(a){this.a=a},
kh(a){var s
if(typeof a=="function")throw A.b(A.a0("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(){return b(c)}}(A.oW,a)
s[$.bG()]=a
return s},
ax(a){var s
if(typeof a=="function")throw A.b(A.a0("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.oX,a)
s[$.bG()]=a
return s},
a7(a){var s
if(typeof a=="function")throw A.b(A.a0("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e){return b(c,d,e,arguments.length)}}(A.oY,a)
s[$.bG()]=a
return s},
ki(a){var s
if(typeof a=="function")throw A.b(A.a0("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f){return b(c,d,e,f,arguments.length)}}(A.oZ,a)
s[$.bG()]=a
return s},
cg(a){var s
if(typeof a=="function")throw A.b(A.a0("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f,g){return b(c,d,e,f,g,arguments.length)}}(A.p_,a)
s[$.bG()]=a
return s},
l6(a){var s
if(typeof a=="function")throw A.b(A.a0("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f,g,h){return b(c,d,e,f,g,h,arguments.length)}}(A.p0,a)
s[$.bG()]=a
return s},
oW(a){return a.$0()},
oX(a,b,c){if(c>=1)return a.$1(b)
return a.$0()},
oY(a,b,c,d){if(d>=2)return a.$2(b,c)
if(d===1)return a.$1(b)
return a.$0()},
oZ(a,b,c,d,e){if(e>=3)return a.$3(b,c,d)
if(e===2)return a.$2(b,c)
if(e===1)return a.$1(b)
return a.$0()},
p_(a,b,c,d,e,f){if(f>=4)return a.$4(b,c,d,e)
if(f===3)return a.$3(b,c,d)
if(f===2)return a.$2(b,c)
if(f===1)return a.$1(b)
return a.$0()},
p0(a,b,c,d,e,f,g){if(g>=5)return a.$5(b,c,d,e,f)
if(g===4)return a.$4(b,c,d,e)
if(g===3)return a.$3(b,c,d)
if(g===2)return a.$2(b,c)
if(g===1)return a.$1(b)
return a.$0()},
kv(a,b){return a[b]},
my(a,b,c){return a[b].apply(a,c)},
q5(a,b){var s,r
if(b==null)return new a()
if(b instanceof Array)switch(b.length){case 0:return new a()
case 1:return new a(b[0])
case 2:return new a(b[0],b[1])
case 3:return new a(b[0],b[1],b[2])
case 4:return new a(b[0],b[1],b[2],b[3])}s=[null]
B.c.a4(s,b)
r=a.bind.apply(a,s)
String(r)
return new r()},
a_(a,b){var s=new A.k($.l,b.h("k<0>")),r=new A.au(s,b.h("au<0>"))
a.then(A.b1(new A.kD(r),1),A.b1(new A.kE(r),1))
return s},
kD:function kD(a){this.a=a},
kE:function kE(a){this.a=a},
jy:function jy(){},
jz:function jz(a){this.a=a},
o7(a){var s
A:{if(18===a){s=B.ag
break A}if(23===a){s=B.ah
break A}if(9===a){s=B.ai
break A}s=null
break A}return s},
cX:function cX(a,b){this.a=a
this.b=b},
an:function an(a,b,c){this.a=a
this.b=b
this.c=c},
lW(a,b,c,d,e,f,g){return new A.bT(d,b,c,e,f,a,g)},
bT:function bT(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g},
hW:function hW(){},
fX:function fX(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.f=_.e=_.d=null
_.r=!1},
h5:function h5(a){this.a=a},
h4:function h4(a){this.a=a},
h6:function h6(a){this.a=a},
h2:function h2(a){this.a=a},
h1:function h1(a){this.a=a},
h3:function h3(a){this.a=a},
fZ:function fZ(a){this.a=a},
fY:function fY(a){this.a=a},
h_:function h_(a){this.a=a},
h0:function h0(a,b){this.a=a
this.b=b},
aZ:function aZ(a,b,c,d,e){var _=this
_.a=a
_.b=!1
_.c=b
_.d=null
_.e=c
_.f=d
_.w=_.r=null
_.$ti=e},
jR:function jR(a,b){this.a=a
this.b=b},
jS:function jS(a,b,c){this.a=a
this.b=b
this.c=c},
jT:function jT(a,b,c){this.a=a
this.b=b
this.c=c},
hV:function hV(){},
bU:function bU(a,b,c){var _=this
_.a=a
_.b=b
_.d=c
_.e=null
_.f=!0
_.r=!1},
kP(a,b){var s=$.f8()
return new A.e8(A.aC(t.N,t.fN),s,a)},
e8:function e8(a,b,c){this.d=a
this.b=b
this.a=c},
eM:function eM(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=0},
qp(a){var s=J.ne(new v.G.URL(a,"file:///").pathname,"/")
return new A.d4(s,new A.kC(),A.aw(s).h("d4<1>"))},
kC:function kC(){},
dS:function dS(a){this.a=a},
hH:function hH(a,b){this.a=a
this.b=b},
o3(a){var s=a.f=!1,r=a.a
r=r.c.d.sqlite3_step(r.b)
A:{if(100===r){s=!0
break A}if(101===r||0===r)break A
s=a.a2(r,"step")}return s},
b8:function b8(){},
hu:function hu(){},
cx:function cx(a){this.a=a},
bl(a){return new A.aW(a)},
lo(a,b){var s,r,q,p
if(b==null)b=$.f8()
for(s=a.length,r=a.$flags|0,q=0;q<s;++q){p=b.bJ(256)
r&2&&A.E(a)
a[q]=p}},
aW:function aW(a){this.a=a},
cW:function cW(a){this.a=a},
U:function U(){},
dR:function dR(){},
dQ:function dQ(){},
qr(a,b){var s=null,r=new A.bc(t.bN)
return A.qs(a,new A.d6(s,s,s,s,s,s,s,s,new A.kG(new A.kF(r,A.kh(new A.kH(r)))),s,s,s,s),b)},
bp:function bp(a){var _=this
_.d=a
_.c=_.b=_.a=null},
kH:function kH(a){this.a=a},
kF:function kF(a,b){this.a=a
this.b=b},
kG:function kG(a){this.a=a},
is:function is(a,b){this.a=a
this.b=b},
im:function im(a,b,c){this.a=a
this.b=b
this.c=c},
iu:function iu(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
it:function it(a,b,c){this.b=a
this.c=b
this.d=c},
bm:function bm(){},
bn:function bn(){},
bX:function bX(a,b,c){this.a=a
this.b=b
this.c=c},
aJ(a,b){var s,r,q,p=null
try{p=a.$0()}catch(q){s=A.R(q)
r=A.Q(q)
$.l.aI(s,r)
p=b}return p},
a4(a){var s,r,q,p=0
try{a.$0()}catch(r){q=A.R(r)
if(q instanceof A.aW){s=q
p=s.a}else{A.Q(r)
p=1}}return p},
dZ:function dZ(a){this.b=this.a=$
this.d=a},
fH:function fH(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
fD:function fD(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
fM:function fM(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
fO:function fO(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
fR:function fR(a,b){this.a=a
this.b=b},
fG:function fG(a,b,c){this.a=a
this.b=b
this.c=c},
fF:function fF(a){this.a=a},
fP:function fP(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
fV:function fV(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
fT:function fT(a,b){this.a=a
this.b=b},
fS:function fS(a,b){this.a=a
this.b=b},
fL:function fL(a,b,c){this.a=a
this.b=b
this.c=c},
fK:function fK(a,b,c){this.a=a
this.b=b
this.c=c},
fN:function fN(a,b){this.a=a
this.b=b},
fU:function fU(a,b){this.a=a
this.b=b},
fE:function fE(a,b,c){this.a=a
this.b=b
this.c=c},
fI:function fI(a){this.a=a},
fJ:function fJ(a,b,c){this.a=a
this.b=b
this.c=c},
fQ:function fQ(a){this.a=a},
fB:function fB(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
fC:function fC(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
fA:function fA(a,b){this.a=a
this.b=b},
fz:function fz(a,b){this.a=a
this.b=b},
fy:function fy(a,b,c){this.a=a
this.b=b
this.c=c},
nQ(a){return new A.dS(a)},
cr:function cr(a,b){this.a=a
this.$ti=b},
fa:function fa(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
fc:function fc(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
fb:function fb(a,b,c){this.a=a
this.b=b
this.c=c},
ar(a,b){var s=new A.k($.l,b.h("k<0>")),r=new A.D(s,b.h("D<0>")),q=t.m
A.a2(a,"success",new A.fp(r,a,b),!1,q)
A.a2(a,"error",new A.fq(r,a),!1,q)
return s},
nr(a,b){var s=new A.k($.l,b.h("k<0>")),r=new A.D(s,b.h("D<0>")),q=t.m
A.a2(a,"success",new A.fu(r,a,b),!1,q)
A.a2(a,"error",new A.fv(r,a),!1,q)
A.a2(a,"blocked",new A.fw(r),!1,q)
return s},
bq:function bq(a,b){var _=this
_.c=_.b=_.a=null
_.d=a
_.$ti=b},
j_:function j_(a,b){this.a=a
this.b=b},
j0:function j0(a,b){this.a=a
this.b=b},
fp:function fp(a,b,c){this.a=a
this.b=b
this.c=c},
fq:function fq(a,b){this.a=a
this.b=b},
fu:function fu(a,b,c){this.a=a
this.b=b
this.c=c},
fv:function fv(a,b){this.a=a
this.b=b},
fw:function fw(a){this.a=a},
kI(){var s=v.G.navigator
if("storage" in s)return s.storage
return null},
lA(a,b,c){var s=a.read(b,c)
return s},
lB(a,b,c){var s=a.write(b,c)
return s},
nz(a){var s=t.cO
if(!(v.G.Symbol.asyncIterator in a))A.y(A.a0("Target object does not implement the async iterable interface",null))
return new A.bs(new A.hg(),new A.cr(a,s),s.h("bs<O.T,m>"))},
hg:function hg(){},
io:function io(a){this.a=a},
ip:function ip(a){this.a=a},
ir(a,b){var s=0,r=A.i(t.n),q,p,o
var $async$ir=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:p=v.G
o=A
s=3
return A.c(A.a_(p.fetch(new p.URL(a,A.Z(p.location).href),null),t.m),$async$ir)
case 3:q=o.iq(d,null)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$ir,r)},
iq(a,b){var s=0,r=A.i(t.n),q,p,o,n,m
var $async$iq=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:p=new A.dZ(A.aC(t.S,t.b9))
o=A
n=A
m=A
s=3
return A.c(new A.io(p).bG(a),$async$iq)
case 3:q=new o.bW(new n.is(m.of(d,p),new A.e4(new WeakMap())))
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$iq,r)},
bW:function bW(a){this.a=a},
oq(a){var s=new A.dg(a,new A.D(new A.k($.l,t.D),t.F),a.objectStore("files"),a.objectStore("blocks"))
s.ev(a)
return s},
ea(a,b,c){var s=0,r=A.i(t.bd),q,p,o,n,m,l
var $async$ea=A.j(function(d,e){if(d===1)return A.e(e,r)
for(;;)switch(s){case 0:p=t.N
o=new A.fh(a)
n=A.kP("dart-memory",null)
m=$.f8()
l=new A.aP(o,n,new A.bc(t.au),A.cI(p),A.aC(p,t.S),m,b)
l.r=!1
s=3
return A.c(o.bK(),$async$ea)
case 3:s=4
return A.c(l.aX(),$async$ea)
case 4:q=l
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$ea,r)},
fh:function fh(a){this.a=null
this.b=a},
fk:function fk(a){this.a=a},
fj:function fj(a,b,c){this.a=a
this.b=b
this.c=c},
fi:function fi(a){this.a=a},
dg:function dg(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=!1
_.d=c
_.e=d},
jt:function jt(a){this.a=a},
ju:function ju(a){this.a=a},
js:function js(a){this.a=a},
jv:function jv(a,b,c){this.a=a
this.b=b
this.c=c},
jx:function jx(a,b){this.a=a
this.b=b},
jw:function jw(a,b){this.a=a
this.b=b},
ja:function ja(a,b,c){this.a=a
this.b=b
this.c=c},
jb:function jb(a,b){this.a=a
this.b=b},
eS:function eS(a,b){this.a=a
this.b=b},
aP:function aP(a,b,c,d,e,f,g){var _=this
_.d=a
_.e=!1
_.f=null
_.r=!0
_.w=b
_.x=c
_.y=d
_.z=e
_.b=f
_.a=g},
hs:function hs(a,b,c){this.a=a
this.b=b
this.c=c},
ht:function ht(){},
hr:function hr(a,b){this.a=a
this.b=b},
eN:function eN(a,b,c){this.a=a
this.b=b
this.c=c},
jr:function jr(a,b){this.a=a
this.b=b},
V:function V(){},
de:function de(a,b){var _=this
_.w=a
_.d=b
_.c=_.b=_.a=null},
da:function da(a,b,c){var _=this
_.w=a
_.x=b
_.d=c
_.c=_.b=_.a=null},
c5:function c5(a,b,c){var _=this
_.w=a
_.x=b
_.d=c
_.c=_.b=_.a=null},
ce:function ce(a,b,c,d,e){var _=this
_.w=a
_.x=b
_.y=c
_.z=d
_.d=e
_.c=_.b=_.a=null},
lU(a){var s=A.kP("dart-memory",null),r=$.f8()
return new A.bS(s,r,a)},
ey(a,b){var s=0,r=A.i(t.cf),q,p,o,n,m,l,k,j
var $async$ey=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:j=A.kI()
if(j==null)throw A.b(A.bl(1))
p=t.m
s=3
return A.c(A.a_(j.getDirectory(),p),$async$ey)
case 3:o=d
n=A.qp(a),m=J.ak(n.a),n=new A.d5(m,n.b),l=null
case 4:if(!n.j()){s=6
break}s=7
return A.c(A.a_(o.getDirectoryHandle(m.gl(),{create:!0}),p),$async$ey)
case 7:k=d
case 5:l=o,o=k
s=4
break
case 6:q=new A.W(l,o)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$ey,r)},
ez(a){var s=0,r=A.i(t.m),q
var $async$ez=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:s=3
return A.c(A.ey(a,!0),$async$ez)
case 3:q=c.b
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$ez,r)},
hT(a,b){var s=0,r=A.i(t.v),q,p
var $async$hT=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:if(A.kI()==null)throw A.b(A.bl(1))
p=A
s=3
return A.c(A.ez(a),$async$hT)
case 3:q=p.hS(d,!1,b)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$hT,r)},
hS(a,b,c){var s=0,r=A.i(t.v),q,p
var $async$hS=A.j(function(d,e){if(d===1)return A.e(e,r)
for(;;)switch(s){case 0:p=A.lU(c)
s=3
return A.c(p.a7(a,!1),$async$hS)
case 3:q=p
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$hS,r)},
bI:function bI(a,b,c){this.c=a
this.a=b
this.b=c},
bS:function bS(a,b,c){var _=this
_.d=null
_.e=a
_.b=b
_.a=c},
hU:function hU(a,b){this.a=a
this.b=b},
eX:function eX(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=0},
jD:function jD(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
of(a,b){var s=A.Z(a.exports.memory)
b.b!==$&&A.mK()
b.b=s
s=new A.ih(s,b,a.exports)
s.es(a,b)
return s},
l1(a,b){var s,r=A.ag(a.buffer,b,null)
for(s=0;r[s]!==0;)++s
return s},
bY(a,b,c){var s=a.buffer
return B.y.dO(A.ag(s,b,c==null?A.l1(a,b):c))},
l0(a,b,c){var s
if(b===0)return null
s=a.buffer
return B.y.dO(A.ag(s,b,c==null?A.l1(a,b):c))},
ih:function ih(a,b,c){var _=this
_.b=a
_.c=b
_.d=c
_.w=_.r=null},
ii:function ii(a){this.a=a},
ij:function ij(a){this.a=a},
ik:function ik(a){this.a=a},
il:function il(a){this.a=a},
kr(){var s=0,r=A.i(t.eJ),q,p,o,n,m,l
var $async$kr=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:m=new v.G.MessageChannel()
l=$.dL()
s=l!=null?3:5
break
case 3:p=A.pw()
s=6
return A.c(A.d3(l,p,null,null,!1),$async$kr)
case 6:o=b
s=4
break
case 5:o=null
p=null
case 4:n=m.port2
q=new A.W({port:m.port1,lockName:p},new A.cu(n,p,o))
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$kr,r)},
pw(){var s,r
for(s=0,r="channel-close-";s<16;++s)r+=A.bh(97+$.n4().bJ(26))
return r.charCodeAt(0)==0?r:r},
ni(a){return new A.dU(a)},
cu:function cu(a,b,c){this.a=a
this.b=b
this.c=c},
hJ:function hJ(){},
hN:function hN(a){this.a=a},
hO:function hO(a){this.a=a},
hM:function hM(a){this.a=a},
hL:function hL(a){this.a=a},
hK:function hK(a){this.a=a},
dU:function dU(a){this.a=a},
fW:function fW(){},
dY:function dY(a){this.a=a},
fx:function fx(a,b){this.c=a
this.a=b},
bo:function bo(){},
e6(a,b,c){var s=0,r=A.i(t.gk),q,p,o
var $async$e6=A.j(function(d,e){if(d===1)return A.e(e,r)
for(;;)switch(s){case 0:s=3
return A.c(A.ez(a),$async$e6)
case 3:p=e
o=A.lU(c)
s=b?4:5
break
case 4:s=6
return A.c(o.a7(p,!0),$async$e6)
case 6:case 5:q=new A.e5(o,p,b)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$e6,r)},
e5:function e5(a,b,c){this.a=a
this.b=b
this.c=c},
hq:function hq(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=0},
d3(a,b,c,d,e){var s,r,q={},p=new A.k($.l,t.cp),o=new A.D(p,t.eP)
q.a=null
s={steal:e}
if(c!=null)s.signal=c
r=t.X
A.kO(A.a_(a.request(b,s,A.ax(new A.iv(q,o))),r),new A.iw(q,d,o),r,t.K)
return p},
iv:function iv(a,b){this.a=a
this.b=b},
iw:function iw(a,b,c){this.a=a
this.b=b
this.c=c},
aA:function aA(a){this.a=a},
e_:function e_(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.f=_.e=null},
h8:function h8(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
h7:function h7(a,b){this.a=a
this.b=b},
h9:function h9(a){this.a=a},
cM:function cM(a){this.a=!1
this.b=a},
hE:function hE(a,b){this.a=a
this.b=b},
hD:function hD(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
hC:function hC(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
no(a){var s,r,q,p,o=A.v([],t.gQ),n=t.c.a(a.a),m=t.r.b(n)?n:new A.ay(n,A.aw(n).h("ay<1,B>"))
for(s=J.dK(m),r=0;r<s.gk(m)/2;++r){q=r*2
o.push(new A.W(A.ly(B.ac,s.n(m,q)),s.n(m,q+1)))}s=A.bx(a.b)
q=A.bx(a.c)
p=A.bx(a.d)
return new A.b9(o,s,q,A.bx(a.g),p)},
b9:function b9(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
o4(a){var s
if(J.N(a.t,"errorResponse")){s=A.nt(a)
if(s!=null&&s instanceof A.b3)return s
else return new A.cU(a.e)}else return new A.cU("Did not respond with expected type, got "+A.u(a))},
nt(a){var s=a.s,r=s==null?null:A.Y(s)
A:{if(0===r){s=A.nu(t.c.a(a.r))
break A}if(1===r){s=B.j
break A}s=null
break A}return s},
nu(a){var s,r,q,p,o=null,n=a.length>=8,m=o,l=o,k=o,j=o,i=o,h=o,g=o
if(n){s=a[0]
m=a[1]
l=a[2]
k=a[3]
j=a[4]
i=a[5]
h=a[6]
g=a[7]}else s=o
if(!n)throw A.b(A.x("Pattern matching error"))
n=new A.he()
l=A.Y(A.by(l))
A.dE(s)
r=n.$1(m)
q=n.$1(j)
if(i!=null&&h!=null){t.c.a(i)
t.a.a(h)
p=new A.aN(i,h,A.ag(h,0,o))}else p=o
n=n.$1(k)
A.mh(g)
return new A.bT(s,r,l,g==null?o:A.Y(g),n,q,p)},
nv(a){var s,r,q,p,o,n,m=null,l=a.r
A:{if(l==null){s=m
break A}s=A.m_(l)
break A}r=a.b
if(r==null)r=m
q=a.e
if(q==null)q=m
p=a.f
if(p==null)p=m
o=s==null
n=o?m:s.a
s=o?m:s.b
o=a.d
if(o==null)o=m
return[a.a,r,a.c,q,p,n,s,o]},
o5(a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=null,a1=v.G,a2=new a1.Array(),a3=new a1.ArrayBuffer(512),a4=new A.hq(a3,512,"transfer" in a3)
a6.dI(a5)
for(s=a5.a,r=s.c,q=s.b,p=r.d,r=r.b,o=0,n=!0;A.o3(a5);){if(n){o=p.sqlite3_column_count(q)
n=!1}m=a4.d
l=a4.d=m+o
if(l>a4.b)a4.eM(l)
l=new a1.DataView(a4.a,m,o)
k=new a1.Array(o)
for(j=0;j<o;++j){switch(p.sqlite3_column_type(q,j)){case 1:i=p.sqlite3_column_int64(q,j)
h=a1.Number(i)
if(a1.Number.isSafeInteger(h)){i=h
g=B.o}else g=B.p
break
case 2:i=p.sqlite3_column_double(q,j)
g=B.q
break
case 3:f=p.sqlite3_column_text(q,j)
e=p.sqlite3_column_bytes(q,j)
d=r.buffer
f=new Uint8Array(d,f,e)
c=new A.cd(!1).bk(f,0,a0,!0)
i=c
g=B.r
break
case 4:f=p.sqlite3_column_bytes(q,j)
b=new Uint8Array(f)
e=p.sqlite3_column_bytes(q,j)
A.bQ(0,e,f)
s.ek(j,b,0,e)
i=b
g=B.t
break
case 5:default:i=a0
g=B.u}k[j]=i
l.setUint8(j,g.a)}a2.push(k)}a=new a1.Array(o)
for(j=0;j<o;++j){a1=p.sqlite3_column_name(q,j)
s=r.buffer
l=A.l1(r,a1)
a1=new Uint8Array(s,a1,l)
a[j]=new A.cd(!1).bk(a1,0,a0,!0)}return A.mD(!1,a,0,0,a2,a0,a4.hS(0))},
qk(a){if(a==="sharedCompatibilityCheck"||a==="dedicatedCompatibilityCheck"||a==="dedicatedInSharedCompatibilityCheck")return!0
else return!1},
he:function he(){},
mD(a,b,c,d,e,f,g){return{c:b,n:f,v:g,r:e,x:a,y:c,i:d,t:"rowsResponse"}},
ck(a){var s,r,q,p,o=v.G,n=new o.Array()
switch(a.t){case"connect":n.push(a.r.port)
break
case"fileSystemAccess":s=a.b
if(s!=null)n.push(s)
break
case"runQuery":n.push(a.v)
break
case"simpleSuccessResponse":r=a.r
if(r!=null){o=o.ArrayBuffer
o=r instanceof o
q=r}else{q=null
o=!1}if(o)n.push(q)
break
case"endpointResponse":n.push(a.r.port)
break
case"rowsResponse":p=a.v
if(p!=null)n.push(p)
break}return n},
qa(a,b,c,d,e){switch(a.t){case"abort":return b.$1(a)
case"notifyUpdate":case"notifyCommit":case"notifyRollback":return c.$1(a)
case"simpleSuccessResponse":case"endpointResponse":case"rowsResponse":case"errorResponse":return e.$1(a)
default:return d.$1(a)}},
ek:function ek(a,b){this.a=a
this.b=b},
hQ:function hQ(){},
nA(a){var s,r
for(s=0;s<5;++s){r=B.a9[s]
if(r.c===a)return r}throw A.b(A.a0("Unknown FS implementation: "+a,null))},
ob(a){var s,r,q,p,o,n,m,l,k,j=null
A:{if(a==null){s=j
r=B.u
break A}q=A.la(a)
p=q?a:j
if(q){s=p
r=B.o
break A}q=a instanceof A.dS
if(q)o=a
else o=j
if(q){s=o.a
r=B.p
break A}q=typeof a=="number"
n=q?a:j
if(q){s=n
r=B.q
break A}q=typeof a=="string"
m=q?a:j
if(q){s=m
r=B.r
break A}q=t.p.b(a)
l=q?a:j
if(q){s=l
r=B.t
break A}q=A.kj(a)
k=q?a:j
if(q){s=k
r=B.I
break A}throw A.b(A.a0("Unsupported value: "+A.u(a),j))}return new A.W(r,s)},
m_(a){var s,r,q,p,o,n
if(a instanceof A.aN)return new A.W(a.a,a.b)
s=[]
r=J.dK(a)
q=r.gk(a)
p=new Uint8Array(q)
for(o=0;o<r.gk(a);++o){n=A.ob(r.n(a,o))
p[o]=n.a.a
s.push(n.b)}return new A.W(s,t.a.a(B.d.ga5(p)))},
aO:function aO(a,b,c){this.c=a
this.a=b
this.b=c},
ao:function ao(a,b){this.a=a
this.b=b},
aN:function aN(a,b,c){this.a=a
this.b=b
this.c=c},
f7(){var s=0,r=A.i(t.y),q,p=2,o=[],n=[],m,l,k,j,i,h
var $async$f7=A.j(function(a,b){if(a===1){o.push(b)
s=p}for(;;)switch(s){case 0:i=v.G
if(!("indexedDB" in i)||!("FileReader" in i)){q=!1
s=1
break}m=A.Z(i.indexedDB)
i=$.dL()
i=i==null?null:A.d3(i,"drift_mock_db",null,null,!1)
s=3
return A.c(t.U.b(i)?i:A.c8(i,t.J),$async$f7)
case 3:l=b
p=5
s=8
return A.c(A.nq(m.open("drift_mock_db"),t.m),$async$f7)
case 8:k=b
k.close()
m.deleteDatabase("drift_mock_db")
n.push(7)
s=6
break
case 5:p=4
h=o.pop()
q=!1
n=[1]
s=6
break
n.push(7)
s=6
break
case 4:n=[2]
case 6:p=2
i=l
if(i!=null)i.a.L()
s=n.pop()
break
case 7:q=!0
s=1
break
case 1:return A.f(q,r)
case 2:return A.e(o.at(-1),r)}})
return A.h($async$f7,r)},
kp(a){return A.q6(a)},
q6(a){var s=0,r=A.i(t.y),q,p=2,o=[],n,m,l,k,j,i
var $async$kp=A.j(function(b,c){if(b===1){o.push(c)
s=p}for(;;)switch(s){case 0:j={}
j.a=null
p=4
n=A.Z(v.G.indexedDB)
m=n.open(a,1)
m.onupgradeneeded=A.ax(new A.kq(j,m))
s=7
return A.c(A.np(m,t.m),$async$kp)
case 7:l=c
if(j.a==null)j.a=!0
l.close()
p=2
s=6
break
case 4:p=3
i=o.pop()
s=6
break
case 3:s=2
break
case 6:j=j.a
q=j===!0
s=1
break
case 1:return A.f(q,r)
case 2:return A.e(o.at(-1),r)}})
return A.h($async$kp,r)},
cm(){var s=0,r=A.i(t.r),q,p=2,o=[],n=[],m,l,k,j,i,h,g
var $async$cm=A.j(function(a,b){if(a===1){o.push(b)
s=p}for(;;)switch(s){case 0:h=A.kI()
if(h==null){q=B.E
s=1
break}j=t.m
s=3
return A.c(A.a_(h.getDirectory(),j),$async$cm)
case 3:m=b
p=5
s=8
return A.c(A.a_(m.getDirectoryHandle("drift_db",{create:!1}),j),$async$cm)
case 8:m=b
p=2
s=7
break
case 5:p=4
g=o.pop()
q=B.E
s=1
break
s=7
break
case 4:s=2
break
case 7:l=A.v([],t.s)
j=new A.bv(A.dJ(A.nz(m),"stream",t.K))
p=9
case 12:s=14
return A.c(j.j(),$async$cm)
case 14:if(!b){s=13
break}k=j.gl()
if(J.N(k.kind,"directory"))J.ln(l,k.name)
s=12
break
case 13:n.push(11)
s=10
break
case 9:n=[2]
case 10:p=2
s=15
return A.c(j.p(),$async$cm)
case 15:s=n.pop()
break
case 11:q=l
s=1
break
case 1:return A.f(q,r)
case 2:return A.e(o.at(-1),r)}})
return A.h($async$cm,r)},
np(a,b){var s=new A.k($.l,b.h("k<0>")),r=new A.D(s,b.h("D<0>")),q=t.m
A.a2(a,"success",new A.fn(r,a,b),!1,q)
A.a2(a,"error",new A.fo(r,a),!1,q)
return s},
nq(a,b){var s=new A.k($.l,b.h("k<0>")),r=new A.D(s,b.h("D<0>")),q=t.m
A.a2(a,"success",new A.fr(r,a,b),!1,q)
A.a2(a,"error",new A.fs(r,a),!1,q)
A.a2(a,"blocked",new A.ft(r,a),!1,q)
return s},
kq:function kq(a,b){this.a=a
this.b=b},
fn:function fn(a,b,c){this.a=a
this.b=b
this.c=c},
fo:function fo(a,b){this.a=a
this.b=b},
fr:function fr(a,b,c){this.a=a
this.b=b
this.c=c},
fs:function fs(a,b){this.a=a
this.b=b},
ft:function ft(a,b){this.a=a
this.b=b},
hI:function hI(a,b){this.a=a
this.b=b},
cB:function cB(a,b){this.a=a
this.b=b},
aU:function aU(a,b){this.a=a
this.b=b},
cU:function cU(a){this.a=a},
b3:function b3(a){this.a=a},
p5(a){var s=a.gdW()
return new A.bs(new A.kg(),s,A.A(s).h("bs<O.T,m>"))},
m2(a,b){var s=A.v([],t.W),r=b==null?a.b:b
return new A.c1(a,r,new A.dw(),new A.dw(),new A.dw(),s)},
om(a,b,c){var s=t.S
s=new A.c_(c,A.v([],t.bZ),a.a,new A.au(new A.k($.l,t.D),t.h),A.aC(s,t.dn),A.aC(s,t.m))
s.er(a)
s.eu(a,b,c)
return s},
mk(a){var s
switch(a.a){case 0:s="/database"
break
case 1:s="/database-journal"
break
default:s=null}return s},
b0(){var s=0,r=A.i(t.eN),q,p=2,o=[],n=[],m,l,k,j,i,h,g,f,e,d,c,b,a
var $async$b0=A.j(function(a0,a1){if(a0===1){o.push(a1)
s=p}for(;;)switch(s){case 0:b=A.kI()
if(b==null){q=B.m
s=1
break}m=null
l=null
k=null
j=null
i=!1
p=4
d=$.dL()
d=d==null?null:A.d3(d,"_drift_feature_detection",null,null,!1)
s=7
return A.c(t.U.b(d)?d:A.c8(d,t.J),$async$b0)
case 7:j=a1
d=t.m
s=8
return A.c(A.a_(b.getDirectory(),d),$async$b0)
case 8:m=a1
s=9
return A.c(A.a_(m.getFileHandle("_drift_feature_detection",{create:!0}),d),$async$b0)
case 9:l=a1
s=10
return A.c(A.dI(l),$async$b0)
case 10:h=a1
g=null
f=null
g=h.a
f=h.b
i=g
k=f
e=A.kQ(k,"getSize",null,null,null,null)
s=typeof e==="object"?11:12
break
case 11:s=13
return A.c(A.a_(A.Z(e),t.X),$async$b0)
case 13:q=B.m
n=[1]
s=5
break
case 12:g=i
q=new A.dr(!0,g)
n=[1]
s=5
break
n.push(6)
s=5
break
case 4:p=3
a=o.pop()
q=B.m
n=[1]
s=5
break
n.push(6)
s=5
break
case 3:n=[2]
case 5:p=2
g=j
if(g!=null)g.a.L()
if(k!=null)k.close()
s=m!=null&&l!=null?14:15
break
case 14:s=16
return A.c(A.a_(m.removeEntry("_drift_feature_detection",{recursive:!1}),t.X),$async$b0)
case 16:case 15:s=n.pop()
break
case 6:case 1:return A.f(q,r)
case 2:return A.e(o.at(-1),r)}})
return A.h($async$b0,r)},
dI(a){return A.pL(a)},
pL(a){var s=0,r=A.i(t.f9),q,p=2,o=[],n,m,l,k,j,i
var $async$dI=A.j(function(b,c){if(b===1){o.push(c)
s=p}for(;;)switch(s){case 0:j=null
p=4
l=t.m
s=7
return A.c(A.a_(a.createSyncAccessHandle({mode:"readwrite-unsafe"}),l),$async$dI)
case 7:j=c
s=8
return A.c(A.a_(a.createSyncAccessHandle({mode:"readwrite-unsafe"}),l),$async$dI)
case 8:n=c
n.close()
l=j
q=new A.W(!0,l)
s=1
break
p=2
s=6
break
case 4:p=3
i=o.pop()
l=j
if(l!=null)l.close()
s=9
return A.c(A.a_(a.createSyncAccessHandle(),t.m),$async$dI)
case 9:m=c
q=new A.W(!1,m)
s=1
break
s=6
break
case 3:s=2
break
case 6:case 1:return A.f(q,r)
case 2:return A.e(o.at(-1),r)}})
return A.h($async$dI,r)},
kg:function kg(){},
dw:function dw(){this.a=null},
c1:function c1(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=null
_.r=1
_.w=f},
iV:function iV(a){this.a=a},
iZ:function iZ(a,b){this.a=a
this.b=b},
iW:function iW(a,b){this.a=a
this.b=b},
iX:function iX(a){this.a=a},
iY:function iY(a,b){this.a=a
this.b=b},
c_:function c_(a,b,c,d,e,f){var _=this
_.w=a
_.x=b
_.a=c
_.b=d
_.d=_.c=null
_.e=0
_.f=e
_.r=f},
iJ:function iJ(a){this.a=a},
iM:function iM(a,b,c){this.a=a
this.b=b
this.c=c},
iP:function iP(a,b){this.a=a
this.b=b},
iS:function iS(a,b,c){this.a=a
this.b=b
this.c=c},
iL:function iL(a,b){this.a=a
this.b=b},
iK:function iK(a,b){this.a=a
this.b=b},
iR:function iR(a,b){this.a=a
this.b=b},
iQ:function iQ(a,b){this.a=a
this.b=b},
iU:function iU(a,b){this.a=a
this.b=b},
iT:function iT(a,b){this.a=a
this.b=b},
iN:function iN(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
iO:function iO(a,b){this.a=a
this.b=b},
iI:function iI(a){this.a=a},
e0:function e0(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.w=1
_.Q=_.z=_.y=_.x=null},
hc:function hc(a){this.a=a},
hb:function hb(a){this.a=a},
ha:function ha(a,b){this.a=a
this.b=b},
ix:function ix(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=0
_.e=d
_.f=0
_.w=_.r=null
_.x=e
_.y=f
_.Q=$},
iy:function iy(a,b){this.a=a
this.b=b},
iz:function iz(a,b){this.a=a
this.b=b},
iA:function iA(a){this.a=a},
og(){var s=v.G
if(A.nK(s,"DedicatedWorkerGlobalScope"))return new A.eG(s,new A.eH(s.location.href))
else return new A.eW(s,new A.eH(s.location.href))},
dC:function dC(){},
eG:function eG(a,b){this.a=a
this.b=b},
eW:function eW(a,b){this.a=a
this.b=b},
jN:function jN(a){this.a=a},
jO:function jO(a,b,c){this.a=a
this.b=b
this.c=c},
jM:function jM(a){this.a=a},
jK:function jK(a){this.a=a},
jL:function jL(a){this.a=a},
eH:function eH(a){this.a=a},
j4:function j4(a){this.a=a},
oa(a){var s={},r=A.v([],t.ey),q=A.cI(t.N)
s.a=A.v([],t.x)
return new A.aI(new A.i9(new A.i4(s,r,a,new A.ia(q),new A.i7(r,q),new A.i8(q)),new A.ib(s,r)),t.aT)},
ia:function ia(a){this.a=a},
i7:function i7(a,b){this.a=a
this.b=b},
i8:function i8(a){this.a=a},
i4:function i4(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
i5:function i5(a){this.a=a},
i6:function i6(a){this.a=a},
ib:function ib(a,b){this.a=a
this.b=b},
i9:function i9(a,b){this.a=a
this.b=b},
i3:function i3(a,b){this.a=a
this.b=b},
bw:function bw(a,b){this.a=a
this.b=b},
aM:function aM(a,b){this.a=a
this.b=b},
on(){return new A.c2()},
fd:function fd(){},
dP:function dP(a,b,c){this.a=a
this.b=b
this.c=c},
fe:function fe(a){this.a=a},
ff:function ff(a,b){this.a=a
this.b=b},
fg:function fg(a,b,c){this.a=a
this.b=b
this.c=c},
c2:function c2(){this.a=!1
this.b=null},
bV:function bV(){},
eO:function eO(){},
at:function at(a,b){this.a=a
this.b=b},
a2(a,b,c,d,e){var s
if(c==null)s=null
else{s=A.mv(new A.j7(c),t.m)
s=s==null?null:A.ax(s)}s=new A.dc(a,b,s,!1,e.h("dc<0>"))
s.ci()
return s},
mv(a,b){var s=$.l
if(s===B.a)return a
return s.cp(a,b)},
kN:function kN(a,b){this.a=a
this.$ti=b},
c6:function c6(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
dc:function dc(a,b,c,d,e){var _=this
_.a=0
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
j7:function j7(a){this.a=a},
j8:function j8(a){this.a=a},
mL(a){return v.mangledGlobalNames[a]},
mH(a){if(typeof dartPrint=="function"){dartPrint(a)
return}if(typeof console=="object"&&typeof console.log!="undefined"){console.log(a)
return}if(typeof print=="function"){print(a)
return}throw"Unable to print message: "+String(a)},
nO(a,b){return b in a},
kQ(a,b,c,d,e,f){var s
if(c==null)return a[b]()
else if(d==null)return a[b](c)
else if(e==null)return a[b](c,d)
else{s=a[b](c,d,e)
return s}},
lf(a,b,c,d,e,f){var s,r=b.a,q=b.b,p=r.d,o=p.sqlite3_extended_errcode(q),n=p.sqlite3_error_offset(q)
A:{if(n<0){n=null
break A}break A}s=a.a
return new A.bT(A.bY(r.b,p.sqlite3_errmsg(q),null),A.bY(s.b,s.d.sqlite3_errstr(o),null)+" (code "+A.u(o)+")",c,n,d,e,f)},
lk(a,b,c,d,e){throw A.b(A.lf(a.a,a.b,b,c,d,e))},
lD(a,b){var s,r
for(s=b,r=0;r<16;++r)s+=A.bh("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012346789".charCodeAt(a.bJ(61)))
return s.charCodeAt(0)==0?s:s},
hP(a){var s=0,r=A.i(t.dI),q
var $async$hP=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:s=3
return A.c(A.a_(a.arrayBuffer(),t.a),$async$hP)
case 3:q=c
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$hP,r)},
lJ(a,b,c,d){A.kQ(a,"setBigInt64",b,c,!0,null)},
qn(){var s=A.og(),r=t.L
new A.ix(s,new A.fd(),A.v([],t.bj),A.aC(t.S,t.eX),new A.cM(A.kT(r)),new A.cM(A.kT(r))).aH()
return null}},B={}
var w=[A,J,B]
var $={}
A.kR.prototype={}
J.eb.prototype={
X(a,b){return a===b},
gv(a){return A.cT(a)},
i(a){return"Instance of '"+A.eu(a)+"'"},
gA(a){return A.bB(A.l7(this))}}
J.ee.prototype={
i(a){return String(a)},
gv(a){return a?519018:218159},
gA(a){return A.bB(t.y)},
$iC:1,
$iS:1}
J.cF.prototype={
X(a,b){return null==b},
i(a){return"null"},
gv(a){return 0},
$iC:1,
$iz:1}
J.I.prototype={$im:1}
J.aR.prototype={
gv(a){return 0},
i(a){return String(a)}}
J.et.prototype={}
J.bj.prototype={}
J.a9.prototype={
i(a){var s=a[$.mN()]
if(s==null)s=a[$.bG()]
if(s==null)return this.en(a)
return"JavaScript function for "+J.aL(s)}}
J.a3.prototype={
gv(a){return 0},
i(a){return String(a)}}
J.bJ.prototype={
gv(a){return 0},
i(a){return String(a)}}
J.p.prototype={
E(a,b){a.$flags&1&&A.E(a,29)
a.push(b)},
u(a,b){var s
a.$flags&1&&A.E(a,"remove",1)
for(s=0;s<a.length;++s)if(J.N(a[s],b)){a.splice(s,1)
return!0}return!1},
a4(a,b){var s
a.$flags&1&&A.E(a,"addAll",2)
if(Array.isArray(b)){this.eB(a,b)
return}for(s=J.ak(b);s.j();)a.push(s.gl())},
eB(a,b){var s,r=b.length
if(r===0)return
if(a===b)throw A.b(A.a5(a))
for(s=0;s<r;++s)a.push(b[s])},
V(a){a.$flags&1&&A.E(a,"clear","clear")
a.length=0},
dY(a,b,c){return new A.aD(a,b,A.aw(a).h("@<1>").M(c).h("aD<1,2>"))},
S(a,b){return A.i1(a,b,null,A.aw(a).c)},
dT(a,b){var s,r,q=a.length
for(s=0;s<q;++s){r=a[s]
if(b.$1(r))return r
if(a.length!==q)throw A.b(A.a5(a))}throw A.b(A.ec())},
C(a,b){return a[b]},
ga6(a){if(a.length>0)return a[0]
throw A.b(A.ec())},
D(a,b,c,d,e){var s,r,q,p,o
a.$flags&2&&A.E(a,5)
A.bQ(b,c,a.length)
s=c-b
if(s===0)return
A.ah(e,"skipCount")
if(t.j.b(d)){r=d
q=e}else{r=J.kM(d,e).cE(0,!1)
q=0}p=J.dK(r)
if(q+s>p.gk(r))throw A.b(A.lF())
if(q<b)for(o=s-1;o>=0;--o)a[b+o]=p.n(r,q+o)
else for(o=0;o<s;++o)a[b+o]=p.n(r,q+o)},
eh(a,b){var s,r,q,p,o
a.$flags&2&&A.E(a,"sort")
s=a.length
if(s<2)return
if(b==null)b=J.pd()
if(s===2){r=a[0]
q=a[1]
if(b.$2(r,q)>0){a[0]=q
a[1]=r}return}p=0
if(A.aw(a).c.b(null))for(o=0;o<a.length;++o)if(a[o]===void 0){a[o]=null;++p}a.sort(A.b1(b,2))
if(p>0)this.fd(a,p)},
eg(a){return this.eh(a,null)},
fd(a,b){var s,r=a.length
for(;s=r-1,r>0;r=s)if(a[s]===null){a[s]=void 0;--b
if(b===0)break}},
i(a){return A.hv(a,"[","]")},
gt(a){return new J.dM(a,a.length,A.aw(a).h("dM<1>"))},
gv(a){return A.cT(a)},
gk(a){return a.length},
n(a,b){if(!(b>=0&&b<a.length))throw A.b(A.lg(a,b))
return a[b]},
q(a,b,c){a.$flags&2&&A.E(a)
if(!(b>=0&&b<a.length))throw A.b(A.lg(a,b))
a[b]=c},
$io:1,
$ir:1}
J.ed.prototype={
hU(a){var s,r,q
if(!Array.isArray(a))return null
s=a.$flags|0
if((s&4)!==0)r="const, "
else if((s&2)!==0)r="unmodifiable, "
else r=(s&1)!==0?"fixed, ":""
q="Instance of '"+A.eu(a)+"'"
if(r==="")return q
return q+" ("+r+"length: "+a.length+")"}}
J.hw.prototype={}
J.dM.prototype={
gl(){var s=this.d
return s==null?this.$ti.c.a(s):s},
j(){var s,r=this,q=r.a,p=q.length
if(r.b!==p)throw A.b(A.T(q))
s=r.c
if(s>=p){r.d=null
return!1}r.d=q[s]
r.c=s+1
return!0}}
J.cG.prototype={
ae(a,b){var s
if(a<b)return-1
else if(a>b)return 1
else if(a===b){if(a===0){s=this.gcv(b)
if(this.gcv(a)===s)return 0
if(this.gcv(a))return-1
return 1}return 0}else if(isNaN(a)){if(isNaN(b))return 0
return 1}else return-1},
gcv(a){return a===0?1/a<0:a<0},
i(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gv(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
bV(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
return s+b},
eq(a,b){if((a|0)===a)if(b>=1||b<-1)return a/b|0
return this.dw(a,b)},
U(a,b){return(a|0)===a?a/b|0:this.dw(a,b)},
dw(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.b(A.bk("Result of truncating division is "+A.u(s)+": "+A.u(a)+" ~/ "+b))},
G(a,b){var s
if(a>0)s=this.fk(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
fk(a,b){return b>31?0:a>>>b},
gA(a){return A.bB(t.o)},
$iK:1}
J.cE.prototype={
gA(a){return A.bB(t.S)},
$iC:1,
$ia:1}
J.ef.prototype={
gA(a){return A.bB(t.i)},
$iC:1}
J.aQ.prototype={
ej(a,b){var s=A.v(a.split(b),t.s)
return s},
cR(a,b,c){return a.substring(b,A.bQ(b,c,a.length))},
cO(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.b(B.Q)
for(s=a,r="";;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
hM(a,b,c){var s=b-a.length
if(s<=0)return a
return this.cO(c,s)+a},
ae(a,b){var s
if(a===b)s=0
else s=a<b?-1:1
return s},
i(a){return a},
gv(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gA(a){return A.bB(t.N)},
gk(a){return a.length},
$iC:1,
$iB:1}
A.aX.prototype={
gt(a){return new A.dT(J.ak(this.gaE()),A.A(this).h("dT<1,2>"))},
gk(a){return J.cp(this.gaE())},
S(a,b){var s=A.A(this)
return A.lt(J.kM(this.gaE(),b),s.c,s.y[1])},
C(a,b){return A.A(this).y[1].a(J.kL(this.gaE(),b))},
i(a){return J.aL(this.gaE())}}
A.dT.prototype={
j(){return this.a.j()},
gl(){return this.$ti.y[1].a(this.a.gl())}}
A.b6.prototype={
gaE(){return this.a}}
A.db.prototype={$io:1}
A.d8.prototype={
n(a,b){return this.$ti.y[1].a(J.n8(this.a,b))},
q(a,b,c){J.lm(this.a,b,this.$ti.c.a(c))},
D(a,b,c,d,e){var s=this.$ti
J.nd(this.a,b,c,A.lt(d,s.y[1],s.c),e)},
R(a,b,c,d){return this.D(0,b,c,d,0)},
$io:1,
$ir:1}
A.ay.prototype={
gaE(){return this.a}}
A.bb.prototype={
i(a){return"LateInitializationError: "+this.a}}
A.kB.prototype={
$0(){return A.hn(null,t.H)},
$S:5}
A.hR.prototype={}
A.o.prototype={}
A.af.prototype={
gt(a){var s=this
return new A.bL(s,s.gk(s),A.A(s).h("bL<af.E>"))},
hy(a,b){var s,r,q,p=this,o=p.gk(p)
if(b.length!==0){if(o===0)return""
s=A.u(p.C(0,0))
if(o!==p.gk(p))throw A.b(A.a5(p))
for(r=s,q=1;q<o;++q){r=r+b+A.u(p.C(0,q))
if(o!==p.gk(p))throw A.b(A.a5(p))}return r.charCodeAt(0)==0?r:r}else{for(q=0,r="";q<o;++q){r+=A.u(p.C(0,q))
if(o!==p.gk(p))throw A.b(A.a5(p))}return r.charCodeAt(0)==0?r:r}},
S(a,b){return A.i1(this,b,null,A.A(this).h("af.E"))}}
A.d_.prototype={
geI(){var s=J.cp(this.a),r=this.c
if(r==null||r>s)return s
return r},
gfl(){var s=J.cp(this.a),r=this.b
if(r>s)return s
return r},
gk(a){var s,r=J.cp(this.a),q=this.b
if(q>=r)return 0
s=this.c
if(s==null||s>=r)return r-q
return s-q},
C(a,b){var s=this,r=s.gfl()+b
if(b<0||r>=s.geI())throw A.b(A.e9(b,s.gk(0),s,null,"index"))
return J.kL(s.a,r)},
S(a,b){var s,r,q=this
A.ah(b,"count")
s=q.b+b
r=q.c
if(r!=null&&s>=r)return new A.cz(q.$ti.h("cz<1>"))
return A.i1(q.a,s,r,q.$ti.c)},
cE(a,b){var s,r,q,p=this,o=p.b,n=p.a,m=J.dK(n),l=m.gk(n),k=p.c
if(k!=null&&k<l)l=k
s=l-o
if(s<=0){n=J.lG(0,p.$ti.c)
return n}r=A.hz(s,m.C(n,o),!1,p.$ti.c)
for(q=1;q<s;++q){r[q]=m.C(n,o+q)
if(m.gk(n)<l)throw A.b(A.a5(p))}return r}}
A.bL.prototype={
gl(){var s=this.d
return s==null?this.$ti.c.a(s):s},
j(){var s,r=this,q=r.a,p=J.dK(q),o=p.gk(q)
if(r.b!==o)throw A.b(A.a5(q))
s=r.c
if(s>=o){r.d=null
return!1}r.d=p.C(q,s);++r.c
return!0}}
A.bd.prototype={
gt(a){var s=this.a
return new A.ej(s.gt(s),this.b,A.A(this).h("ej<1,2>"))},
gk(a){var s=this.a
return s.gk(s)},
C(a,b){var s=this.a
return this.b.$1(s.C(s,b))}}
A.cy.prototype={$io:1}
A.ej.prototype={
j(){var s=this,r=s.b
if(r.j()){s.a=s.c.$1(r.gl())
return!0}s.a=null
return!1},
gl(){var s=this.a
return s==null?this.$ti.y[1].a(s):s}}
A.aD.prototype={
gk(a){return J.cp(this.a)},
C(a,b){return this.b.$1(J.kL(this.a,b))}}
A.d4.prototype={
gt(a){return new A.d5(J.ak(this.a),this.b)}}
A.d5.prototype={
j(){var s,r
for(s=this.a,r=this.b;s.j();)if(r.$1(s.gl()))return!0
return!1},
gl(){return this.a.gl()}}
A.aF.prototype={
S(a,b){A.f9(b,"count")
A.ah(b,"count")
return new A.aF(this.a,this.b+b,A.A(this).h("aF<1>"))},
gt(a){var s=this.a
return new A.eA(s.gt(s),this.b)}}
A.bH.prototype={
gk(a){var s=this.a,r=s.gk(s)-this.b
if(r>=0)return r
return 0},
S(a,b){A.f9(b,"count")
A.ah(b,"count")
return new A.bH(this.a,this.b+b,this.$ti)},
$io:1}
A.eA.prototype={
j(){var s,r
for(s=this.a,r=0;r<this.b;++r)s.j()
this.b=0
return s.j()},
gl(){return this.a.gl()}}
A.cz.prototype={
gt(a){return B.J},
gk(a){return 0},
C(a,b){throw A.b(A.ac(b,0,0,"index",null))},
S(a,b){A.ah(b,"count")
return this}}
A.e3.prototype={
j(){return!1},
gl(){throw A.b(A.ec())}}
A.cC.prototype={}
A.dD.prototype={}
A.W.prototype={$r:"+(1,2)",$s:1}
A.dr.prototype={$r:"+basicSupport,supportsReadWriteUnsafe(1,2)",$s:2}
A.ds.prototype={$r:"+controller,sync(1,2)",$s:3}
A.ca.prototype={$r:"+file,outFlags(1,2)",$s:4}
A.eU.prototype={$r:"+result,resultCode(1,2)",$s:5}
A.cv.prototype={
i(a){return A.kU(this)},
gbt(){return new A.cb(this.h5(),A.A(this).h("cb<a6<1,2>>"))},
h5(){var s=this
return function(){var r=0,q=1,p=[],o,n,m
return function $async$gbt(a,b,c){if(b===1){p.push(c)
r=q}for(;;)switch(r){case 0:o=s.gb7(),o=o.gt(o),n=A.A(s).h("a6<1,2>")
case 2:if(!o.j()){r=3
break}m=o.gl()
r=4
return a.b=new A.a6(m,s.n(0,m),n),1
case 4:r=2
break
case 3:return 0
case 1:return a.c=p.at(-1),3}}}},
$iaS:1}
A.cw.prototype={
gk(a){return this.b.length},
gdg(){var s=this.$keys
if(s==null){s=Object.keys(this.a)
this.$keys=s}return s},
Z(a){if(typeof a!="string")return!1
if("__proto__"===a)return!1
return this.a.hasOwnProperty(a)},
n(a,b){if(!this.Z(b))return null
return this.b[this.a[b]]},
bv(a,b){var s,r,q=this.gdg(),p=this.b
for(s=q.length,r=0;r<s;++r)b.$2(q[r],p[r])},
gb7(){return new A.dh(this.gdg(),this.$ti.h("dh<1>"))}}
A.dh.prototype={
gk(a){return this.a.length},
gt(a){var s=this.a
return new A.eP(s,s.length,this.$ti.h("eP<1>"))}}
A.eP.prototype={
gl(){var s=this.d
return s==null?this.$ti.c.a(s):s},
j(){var s=this,r=s.c
if(r>=s.b){s.d=null
return!1}s.d=s.a[r]
s.c=r+1
return!0}}
A.cV.prototype={}
A.ic.prototype={
W(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.cR.prototype={
i(a){return"Null check operator used on a null value"}}
A.eg.prototype={
i(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.eC.prototype={
i(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.hG.prototype={
i(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.cA.prototype={}
A.du.prototype={
i(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$iJ:1}
A.b7.prototype={
i(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.mM(r==null?"unknown":r)+"'"},
giB(){return this},
$C:"$1",
$R:1,
$D:null}
A.fl.prototype={$C:"$0",$R:0}
A.fm.prototype={$C:"$2",$R:2}
A.i2.prototype={}
A.hX.prototype={
i(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.mM(s)+"'"}}
A.cs.prototype={
X(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.cs))return!1
return this.$_target===b.$_target&&this.a===b.a},
gv(a){return(A.mF(this.a)^A.cT(this.$_target))>>>0},
i(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.eu(this.a)+"'")}}
A.ex.prototype={
i(a){return"RuntimeError: "+this.a}}
A.ba.prototype={
gk(a){return this.a},
gb7(){return new A.aB(this,A.A(this).h("aB<1>"))},
gbt(){return new A.cH(this,A.A(this).h("cH<1,2>"))},
Z(a){var s,r
if(typeof a=="string"){s=this.b
if(s==null)return!1
return s[a]!=null}else if(typeof a=="number"&&(a&0x3fffffff)===a){r=this.c
if(r==null)return!1
return r[a]!=null}else return this.hu(a)},
hu(a){var s=this.d
if(s==null)return!1
return this.bE(this.dd(s,a),a)>=0},
a4(a,b){b.bv(0,new A.hx(this))},
n(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.hv(b)},
hv(a){var s,r,q=this.d
if(q==null)return null
s=this.dd(q,a)
r=this.bE(s,a)
if(r<0)return null
return s[r].b},
q(a,b,c){var s,r,q=this
if(typeof b=="string"){s=q.b
q.cT(s==null?q.b=q.c8():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=q.c
q.cT(r==null?q.c=q.c8():r,b,c)}else q.hx(b,c)},
hx(a,b){var s,r,q,p=this,o=p.d
if(o==null)o=p.d=p.c8()
s=p.ct(a)
r=o[s]
if(r==null)o[s]=[p.bX(a,b)]
else{q=p.bE(r,a)
if(q>=0)r[q].b=b
else r.push(p.bX(a,b))}},
e1(a,b){var s,r,q=this
if(q.Z(a)){s=q.n(0,a)
return s==null?A.A(q).y[1].a(s):s}r=b.$0()
q.q(0,a,r)
return r},
u(a,b){var s=this
if(typeof b=="string")return s.dq(s.b,b)
else if(typeof b=="number"&&(b&0x3fffffff)===b)return s.dq(s.c,b)
else return s.hw(b)},
hw(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=o.ct(a)
r=n[s]
q=o.bE(r,a)
if(q<0)return null
p=r.splice(q,1)[0]
o.dB(p)
if(r.length===0)delete n[s]
return p.b},
V(a){var s=this
if(s.a>0){s.b=s.c=s.d=s.e=s.f=null
s.a=0
s.bW()}},
bv(a,b){var s=this,r=s.e,q=s.r
while(r!=null){b.$2(r.a,r.b)
if(q!==s.r)throw A.b(A.a5(s))
r=r.c}},
cT(a,b,c){var s=a[b]
if(s==null)a[b]=this.bX(b,c)
else s.b=c},
dq(a,b){var s
if(a==null)return null
s=a[b]
if(s==null)return null
this.dB(s)
delete a[b]
return s.b},
bW(){this.r=this.r+1&1073741823},
bX(a,b){var s,r=this,q=new A.hy(a,b)
if(r.e==null)r.e=r.f=q
else{s=r.f
s.toString
q.d=s
r.f=s.c=q}++r.a
r.bW()
return q},
dB(a){var s=this,r=a.d,q=a.c
if(r==null)s.e=q
else r.c=q
if(q==null)s.f=r
else q.d=r;--s.a
s.bW()},
ct(a){return J.a8(a)&1073741823},
dd(a,b){return a[this.ct(b)]},
bE(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.N(a[r].a,b))return r
return-1},
i(a){return A.kU(this)},
c8(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s}}
A.hx.prototype={
$2(a,b){this.a.q(0,a,b)},
$S(){return A.A(this.a).h("~(1,2)")}}
A.hy.prototype={}
A.aB.prototype={
gk(a){return this.a.a},
gt(a){var s=this.a
return new A.ei(s,s.r,s.e)}}
A.ei.prototype={
gl(){return this.d},
j(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.b(A.a5(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.a
r.c=s.c
return!0}}}
A.bK.prototype={
gl(){return this.d},
j(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.b(A.a5(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=s.b
r.c=s.c
return!0}}}
A.cH.prototype={
gk(a){return this.a.a},
gt(a){var s=this.a
return new A.eh(s,s.r,s.e,this.$ti.h("eh<1,2>"))}}
A.eh.prototype={
gl(){var s=this.d
s.toString
return s},
j(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.b(A.a5(q))
s=r.c
if(s==null){r.d=null
return!1}else{r.d=new A.a6(s.a,s.b,r.$ti.h("a6<1,2>"))
r.c=s.c
return!0}}}
A.kw.prototype={
$1(a){return this.a(a)},
$S:33}
A.kx.prototype={
$2(a,b){return this.a(a,b)},
$S:69}
A.ky.prototype={
$1(a){return this.a(a)},
$S:30}
A.dq.prototype={
i(a){return this.dA(!1)},
dA(a){var s,r,q,p,o,n=this.eJ(),m=this.de(),l=(a?"Record ":"")+"("
for(s=n.length,r="",q=0;q<s;++q,r=", "){l+=r
p=n[q]
if(typeof p=="string")l=l+p+": "
o=m[q]
l=a?l+A.lR(o):l+A.u(o)}l+=")"
return l.charCodeAt(0)==0?l:l},
eJ(){var s,r=this.$s
while($.jF.length<=r)$.jF.push(null)
s=$.jF[r]
if(s==null){s=this.eF()
$.jF[r]=s}return s},
eF(){var s,r,q,p=this.$r,o=p.indexOf("("),n=p.substring(1,o),m=p.substring(o),l=m==="()"?0:m.replace(/[^,]/g,"").length+1,k=A.v(new Array(l),t.f)
for(s=0;s<l;++s)k[s]=s
if(n!==""){r=n.split(",")
s=r.length
for(q=l;s>0;){--q;--s
k[q]=r[s]}}k=A.nW(k,!1,t.K)
k.$flags=3
return k}}
A.eT.prototype={
de(){return[this.a,this.b]},
X(a,b){if(b==null)return!1
return b instanceof A.eT&&this.$s===b.$s&&J.N(this.a,b.a)&&J.N(this.b,b.b)},
gv(a){return A.kV(this.$s,this.a,this.b,B.f)}}
A.iH.prototype={}
A.bN.prototype={
gA(a){return B.ak},
dF(a,b,c){A.f5(a,b,c)
return c==null?new Uint8Array(a,b):new Uint8Array(a,b,c)},
$iC:1,
$ib5:1}
A.bM.prototype={$ibM:1}
A.cP.prototype={
ga5(a){if(((a.$flags|0)&2)!==0)return new A.f1(a.buffer)
else return a.buffer},
eZ(a,b,c,d){var s=A.ac(b,0,c,d,null)
throw A.b(s)},
cZ(a,b,c,d){if(b>>>0!==b||b>c)this.eZ(a,b,c,d)}}
A.f1.prototype={
dF(a,b,c){var s=A.ag(this.a,b,c)
s.$flags=3
return s},
$ib5:1}
A.cN.prototype={
gA(a){return B.al},
$iC:1}
A.bO.prototype={
gk(a){return a.length},
fj(a,b,c,d,e){var s,r,q=a.length
this.cZ(a,b,q,"start")
this.cZ(a,c,q,"end")
if(b>c)throw A.b(A.ac(b,0,c,null,null))
s=c-b
if(e<0)throw A.b(A.a0(e,null))
r=d.length
if(r-e<s)throw A.b(A.x("Not enough elements"))
if(e!==0||r!==s)d=d.subarray(e,e+s)
a.set(d,b)},
$iaa:1}
A.cO.prototype={
n(a,b){A.aK(b,a,a.length)
return a[b]},
q(a,b,c){a.$flags&2&&A.E(a)
A.aK(b,a,a.length)
a[b]=c},
D(a,b,c,d,e){a.$flags&2&&A.E(a,5)
this.cS(a,b,c,d,e)},
R(a,b,c,d){return this.D(a,b,c,d,0)},
$io:1,
$ir:1}
A.ab.prototype={
q(a,b,c){a.$flags&2&&A.E(a)
A.aK(b,a,a.length)
a[b]=c},
D(a,b,c,d,e){a.$flags&2&&A.E(a,5)
if(t.eB.b(d)){this.fj(a,b,c,d,e)
return}this.cS(a,b,c,d,e)},
R(a,b,c,d){return this.D(a,b,c,d,0)},
$io:1,
$ir:1}
A.el.prototype={
gA(a){return B.am},
$iC:1}
A.em.prototype={
gA(a){return B.an},
$iC:1}
A.en.prototype={
gA(a){return B.ao},
n(a,b){A.aK(b,a,a.length)
return a[b]},
$iC:1}
A.eo.prototype={
gA(a){return B.ap},
n(a,b){A.aK(b,a,a.length)
return a[b]},
$iC:1}
A.ep.prototype={
gA(a){return B.aq},
n(a,b){A.aK(b,a,a.length)
return a[b]},
$iC:1}
A.eq.prototype={
gA(a){return B.as},
n(a,b){A.aK(b,a,a.length)
return a[b]},
$iC:1}
A.er.prototype={
gA(a){return B.at},
n(a,b){A.aK(b,a,a.length)
return a[b]},
$iC:1}
A.cQ.prototype={
gA(a){return B.au},
gk(a){return a.length},
n(a,b){A.aK(b,a,a.length)
return a[b]},
$iC:1}
A.bf.prototype={
gA(a){return B.av},
gk(a){return a.length},
n(a,b){A.aK(b,a,a.length)
return a[b]},
$iC:1,
$ibf:1,
$ibi:1}
A.dk.prototype={}
A.dl.prototype={}
A.dm.prototype={}
A.dn.prototype={}
A.am.prototype={
h(a){return A.dB(v.typeUniverse,this,a)},
M(a){return A.md(v.typeUniverse,this,a)}}
A.eL.prototype={}
A.jW.prototype={
i(a){return A.ae(this.a,null)}}
A.eJ.prototype={
i(a){return this.a}}
A.dx.prototype={$iaG:1}
A.iC.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:18}
A.iB.prototype={
$1(a){var s,r
this.a.a=a
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:51}
A.iD.prototype={
$0(){this.a.$0()},
$S:2}
A.iE.prototype={
$0(){this.a.$0()},
$S:2}
A.f0.prototype={
ex(a,b){if(self.setTimeout!=null)self.setTimeout(A.b1(new A.jV(this,b),0),a)
else throw A.b(A.bk("`setTimeout()` not found."))},
ey(a,b){if(self.setTimeout!=null)self.setInterval(A.b1(new A.jU(this,a,Date.now(),b),0),a)
else throw A.b(A.bk("Periodic timer."))}}
A.jV.prototype={
$0(){this.a.c=1
this.b.$0()},
$S:0}
A.jU.prototype={
$0(){var s,r=this,q=r.a,p=q.c+1,o=r.b
if(o>0){s=Date.now()-r.c
if(s>(p+1)*o)p=B.b.eq(s,o)}q.c=p
r.d.$1(q)},
$S:2}
A.d7.prototype={
B(a){var s,r=this
if(a==null)a=r.$ti.c.a(a)
if(!r.b)r.a.aT(a)
else{s=r.a
if(r.$ti.h("w<1>").b(a))s.cY(a)
else s.aU(a)}},
af(a,b){var s
if(b==null)b=A.cq(a)
s=this.a
if(this.b)s.K(new A.H(a,b))
else s.a3(new A.H(a,b))},
H(a){return this.af(a,null)},
$ict:1}
A.kd.prototype={
$1(a){return this.a.$2(0,a)},
$S:9}
A.ke.prototype={
$2(a,b){this.a.$2(1,new A.cA(a,b))},
$S:34}
A.ko.prototype={
$2(a,b){this.a(a,b)},
$S:40}
A.eZ.prototype={
gl(){return this.b},
fe(a,b){var s,r,q
a=a
b=b
s=this.a
for(;;)try{r=s(this,a,b)
return r}catch(q){b=q
a=1}},
j(){var s,r,q,p,o=this,n=null,m=0
for(;;){s=o.d
if(s!=null)try{if(s.j()){o.b=s.gl()
return!0}else o.d=null}catch(r){n=r
m=1
o.d=null}q=o.fe(m,n)
if(1===q)return!0
if(0===q){o.b=null
p=o.e
if(p==null||p.length===0){o.a=A.m7
return!1}o.a=p.pop()
m=0
n=null
continue}if(2===q){m=0
n=null
continue}if(3===q){n=o.c
o.c=null
p=o.e
if(p==null||p.length===0){o.b=null
o.a=A.m7
throw n
return!1}o.a=p.pop()
m=1
continue}throw A.b(A.x("sync*"))}return!1},
iD(a){var s,r,q=this
if(a instanceof A.cb){s=a.a()
r=q.e
if(r==null)r=q.e=[]
r.push(q.a)
q.a=s
return 2}else{q.d=J.ak(a)
return 2}}}
A.cb.prototype={
gt(a){return new A.eZ(this.a())}}
A.H.prototype={
i(a){return A.u(this.a)},
$iF:1,
gaa(){return this.b}}
A.hp.prototype={
$2(a,b){var s=this,r=s.a,q=--r.b
if(r.a!=null){r.a=null
r.d=a
r.c=b
if(q===0||s.c)s.d.K(new A.H(a,b))}else if(q===0&&!s.c){q=r.d
q.toString
r=r.c
r.toString
s.d.K(new A.H(q,r))}},
$S:10}
A.ho.prototype={
$1(a){var s,r,q,p,o,n,m=this,l=m.a,k=--l.b,j=l.a
if(j!=null){J.lm(j,m.b,a)
if(J.N(k,0)){l=m.d
s=A.v([],l.h("p<0>"))
for(q=j,p=q.length,o=0;o<q.length;q.length===p||(0,A.T)(q),++o){r=q[o]
n=r
if(n==null)n=l.a(n)
J.ln(s,n)}m.c.aU(s)}}else if(J.N(k,0)&&!m.f){s=l.d
s.toString
l=l.c
l.toString
m.c.K(new A.H(s,l))}},
$S(){return this.d.h("z(0)")}}
A.hi.prototype={
$2(a,b){if(!this.a.b(a))throw A.b(a)
return this.c.$2(a,b)},
$S(){return this.d.h("0/(d,J)")}}
A.hj.prototype={
$1(a){var s,r,q,p,o,n,m=this
if(a===0){s=A.v([],m.c.h("p<0>"))
for(r=m.b,q=r.length,p=0;p<r.length;r.length===q||(0,A.T)(r),++p){o=r[p]
n=o.b
if(n==null)o.$ti.c.a(n)
s.push(n)}m.a.B(s)}else{s=A.v([],t.gz)
for(r=m.b,q=r.length,p=0;p<r.length;r.length===q||(0,A.T)(r),++p)s.push(r[p].c)
q=A.v([],m.c.h("p<0?>"))
for(n=r.length,p=0;p<r.length;r.length===n||(0,A.T)(r),++p)q.push(r[p].b)
m.a.H(new A.cS(B.c.dT(s,A.pR()),a))}},
$S:4}
A.cS.prototype={
i(a){var s,r,q="ParallelWaitError",p=this.c
if(p==null){p=this.d
s=p<=1
if(s)return q
return"ParallelWaitError("+p+" errors)"}s=this.d
r=s>1
if(r)s="("+s+" errors)"
else s=""
return q+s+": "+A.u(p.a)},
gaa(){var s=this.c
s=s==null?null:s.b
return s==null?A.F.prototype.gaa.call(this):s}}
A.df.prototype={
fp(a){this.a.am(new A.je(this,a),new A.jf(this,a),t.P)}}
A.je.prototype={
$1(a){this.a.b=a
this.b.$1(0)},
$S(){return this.a.$ti.h("z(1)")}}
A.jf.prototype={
$2(a,b){this.a.c=new A.H(a,b)
this.b.$1(1)},
$S:11}
A.jd.prototype={
$1(a){var s=this.a,r=s.a+=a
if(++s.b===this.b.length)this.c.$1(r)},
$S:4}
A.c0.prototype={
af(a,b){if((this.a.a&30)!==0)throw A.b(A.x("Future already completed"))
this.K(A.l8(a,b))},
H(a){return this.af(a,null)},
$ict:1}
A.au.prototype={
B(a){var s=this.a
if((s.a&30)!==0)throw A.b(A.x("Future already completed"))
s.aT(a)},
L(){return this.B(null)},
K(a){this.a.a3(a)}}
A.D.prototype={
B(a){var s=this.a
if((s.a&30)!==0)throw A.b(A.x("Future already completed"))
s.aw(a)},
L(){return this.B(null)},
K(a){this.a.K(a)}}
A.av.prototype={
hG(a){if((this.c&15)!==6)return!0
return this.b.b.bd(this.d,a.a,t.y,t.K)},
hi(a){var s,r=this.e,q=null,p=t.z,o=t.K,n=a.a,m=this.b.b
if(t.R.b(r))q=m.cD(r,n,a.b,p,o,t.l)
else q=m.bd(r,n,p,o)
try{p=q
return p}catch(s){if(t.eK.b(A.R(s))){if((this.c&1)!==0)throw A.b(A.a0("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.b(A.a0("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.k.prototype={
am(a,b,c){var s,r,q=$.l
if(q===B.a){if(b!=null&&!t.R.b(b)&&!t.E.b(b))throw A.b(A.b4(b,"onError",u.c))}else{a=q.aK(a,c.h("0/"),this.$ti.c)
if(b!=null)b=A.py(b,q)}s=new A.k($.l,c.h("k<0>"))
r=b==null?1:3
this.aS(new A.av(s,r,a,b,this.$ti.h("@<1>").M(c).h("av<1,2>")))
return s},
bf(a,b){return this.am(a,null,b)},
dz(a,b,c){var s=new A.k($.l,c.h("k<0>"))
this.aS(new A.av(s,19,a,b,this.$ti.h("@<1>").M(c).h("av<1,2>")))
return s},
J(a){var s=this.$ti,r=$.l,q=new A.k(r,s)
if(r!==B.a)a=r.ak(a,t.z)
this.aS(new A.av(q,8,a,null,s.h("av<1,1>")))
return q},
fh(a){this.a=this.a&1|16
this.c=a},
bj(a){this.a=a.a&30|this.a&1
this.c=a.c},
aS(a){var s=this,r=s.a
if(r<=3){a.a=s.c
s.c=a}else{if((r&4)!==0){r=s.c
if((r.a&24)===0){r.aS(a)
return}s.bj(r)}s.b.a9(new A.jg(s,a))}},
dj(a){var s,r,q,p,o,n=this,m={}
m.a=a
if(a==null)return
s=n.a
if(s<=3){r=n.c
n.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){s=n.c
if((s.a&24)===0){s.dj(a)
return}n.bj(s)}m.a=n.bn(a)
n.b.a9(new A.jl(m,n))}},
aY(){var s=this.c
this.c=null
return this.bn(s)},
bn(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
aw(a){var s,r=this
if(r.$ti.h("w<1>").b(a))A.jj(a,r,!0)
else{s=r.aY()
r.a=8
r.c=a
A.br(r,s)}},
aU(a){var s=this,r=s.aY()
s.a=8
s.c=a
A.br(s,r)},
eE(a){var s,r,q,p=this
if((a.a&16)!==0){s=p.b
r=a.b
s=!(s===r||s.ga_()===r.ga_())}else s=!1
if(s)return
q=p.aY()
p.bj(a)
A.br(p,q)},
K(a){var s=this.aY()
this.fh(a)
A.br(this,s)},
eD(a,b){this.K(new A.H(a,b))},
aT(a){if(this.$ti.h("w<1>").b(a)){this.cY(a)
return}this.cW(a)},
cW(a){this.a^=2
this.b.a9(new A.ji(this,a))},
cY(a){A.jj(a,this,!1)
return},
a3(a){this.a^=2
this.b.a9(new A.jh(this,a))},
$iw:1}
A.jg.prototype={
$0(){A.br(this.a,this.b)},
$S:0}
A.jl.prototype={
$0(){A.br(this.b,this.a.a)},
$S:0}
A.jk.prototype={
$0(){A.jj(this.a.a,this.b,!0)},
$S:0}
A.ji.prototype={
$0(){this.a.aU(this.b)},
$S:0}
A.jh.prototype={
$0(){this.a.K(this.b)},
$S:0}
A.jo.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.al(q.d,t.z)}catch(p){s=A.R(p)
r=A.Q(p)
if(k.c&&k.b.a.c.a===s){q=k.a
q.c=k.b.a.c}else{q=s
o=r
if(o==null)o=A.cq(q)
n=k.a
n.c=new A.H(q,o)
q=n}q.b=!0
return}if(j instanceof A.k&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=j.c
q.b=!0}return}if(j instanceof A.k){m=k.b.a
l=new A.k(m.b,m.$ti)
j.am(new A.jp(l,m),new A.jq(l),t.H)
q=k.a
q.c=l
q.b=!1}},
$S:0}
A.jp.prototype={
$1(a){this.a.eE(this.b)},
$S:18}
A.jq.prototype={
$2(a,b){this.a.K(new A.H(a,b))},
$S:11}
A.jn.prototype={
$0(){var s,r,q,p,o,n
try{q=this.a
p=q.a
o=p.$ti
q.c=p.b.b.bd(p.d,this.b,o.h("2/"),o.c)}catch(n){s=A.R(n)
r=A.Q(n)
q=s
p=r
if(p==null)p=A.cq(q)
o=this.a
o.c=new A.H(q,p)
o.b=!0}},
$S:0}
A.jm.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=l.a.a.c
p=l.b
if(p.a.hG(s)&&p.a.e!=null){p.c=p.a.hi(s)
p.b=!1}}catch(o){r=A.R(o)
q=A.Q(o)
p=l.a.a.c
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.cq(p)
m=l.b
m.c=new A.H(p,n)
p=m}p.b=!0}},
$S:0}
A.eD.prototype={}
A.O.prototype={
gk(a){var s={},r=new A.k($.l,t.B)
s.a=0
this.I(new A.i_(s,this),!0,new A.i0(s,r),r.gd2())
return r},
ga6(a){var s=new A.k($.l,A.A(this).h("k<O.T>")),r=this.I(null,!0,new A.hY(s),s.gd2())
r.dZ(new A.hZ(this,r,s))
return s}}
A.i_.prototype={
$1(a){++this.a.a},
$S(){return A.A(this.b).h("~(O.T)")}}
A.i0.prototype={
$0(){this.b.aw(this.a.a)},
$S:0}
A.hY.prototype={
$0(){var s,r=A.lX(),q=new A.as("No element")
A.ev(q,r)
s=A.f6(q,r)
if(s==null)s=new A.H(q,r)
this.a.K(s)},
$S:0}
A.hZ.prototype={
$1(a){A.p1(this.b,this.c,a)},
$S(){return A.A(this.a).h("~(O.T)")}}
A.bu.prototype={
gf6(){if((this.b&8)===0)return this.a
return this.a.gcl()},
aV(){var s,r=this
if((r.b&8)===0){s=r.a
return s==null?r.a=new A.dp():s}s=r.a.gcl()
return s},
gP(){var s=this.a
return(this.b&8)!==0?s.gcl():s},
ab(){if((this.b&4)!==0)return new A.as("Cannot add event after closing")
return new A.as("Cannot add event while adding a stream")},
d7(){var s=this.c
if(s==null)s=this.c=(this.b&2)!==0?$.cn():new A.k($.l,t.D)
return s},
E(a,b){var s=this,r=s.b
if(r>=4)throw A.b(s.ab())
if((r&1)!==0)s.ac(b)
else if((r&3)===0)s.aV().E(0,new A.aY(b))},
dE(a,b){var s,r,q=this
if(q.b>=4)throw A.b(q.ab())
s=A.l8(a,b)
a=s.a
b=s.b
r=q.b
if((r&1)!==0)q.b_(a,b)
else if((r&3)===0)q.aV().E(0,new A.d9(a,b))},
ft(a){return this.dE(a,null)},
m(){var s=this,r=s.b
if((r&4)!==0)return s.d7()
if(r>=4)throw A.b(s.ab())
r=s.b=r|4
if((r&1)!==0)s.aZ()
else if((r&3)===0)s.aV().E(0,B.k)
return s.d7()},
dv(a,b,c,d){var s,r,q,p,o,n,m,l,k,j,i=this
if((i.b&3)!==0)throw A.b(A.x("Stream has already been listened to."))
s=A.A(i)
r=$.l
q=d?1:0
p=b!=null?32:0
o=A.l2(r,a,s.c)
n=A.m1(r,b)
m=c==null?A.pT():c
l=new A.c4(i,o,n,r.ak(m,t.H),r,q|p,s.h("c4<1>"))
k=i.gf6()
if(((i.b|=1)&8)!==0){j=i.a
j.scl(l)
j.aL()}else i.a=l
l.fi(k)
l.c4(new A.jQ(i))
return l},
fb(a){var s,r,q,p,o,n,m,l=this,k=null
if((l.b&8)!==0)k=l.a.p()
l.a=null
l.b=l.b&4294967286|2
s=l.r
if(s!=null)if(k==null)try{r=s.$0()
if(r instanceof A.k)k=r}catch(o){q=A.R(o)
p=A.Q(o)
n=new A.k($.l,t.D)
n.a3(new A.H(q,p))
k=n}else k=k.J(s)
m=new A.jP(l)
if(k!=null)k=k.J(m)
else m.$0()
return k}}
A.jQ.prototype={
$0(){A.lc(this.a.d)},
$S:0}
A.jP.prototype={
$0(){var s=this.a.c
if(s!=null&&(s.a&30)===0)s.aT(null)},
$S:0}
A.f_.prototype={
ac(a){this.gP().av(a)},
b_(a,b){this.gP().aR(a,b)},
aZ(){this.gP().d_()}}
A.eE.prototype={
ac(a){this.gP().au(new A.aY(a))},
b_(a,b){this.gP().au(new A.d9(a,b))},
aZ(){this.gP().au(B.k)}}
A.bZ.prototype={}
A.cc.prototype={}
A.c3.prototype={
gv(a){return(A.cT(this.a)^892482866)>>>0},
X(a,b){if(b==null)return!1
if(this===b)return!0
return b instanceof A.c3&&b.a===this.a}}
A.c4.prototype={
ca(){return this.w.fb(this)},
aB(){var s=this.w
if((s.b&8)!==0)s.a.bL()
A.lc(s.e)},
aC(){var s=this.w
if((s.b&8)!==0)s.a.aL()
A.lc(s.f)}}
A.ad.prototype={
fi(a){var s=this
if(a==null)return
s.r=a
if(a.c!=null){s.e=(s.e|128)>>>0
a.bh(s)}},
dZ(a){this.a=A.l2(this.d,a,A.A(this).h("ad.T"))},
bM(a){var s,r=this,q=r.e
if((q&8)!==0)return
r.e=(q+256|4)>>>0
if(a!=null)a.J(r.ghO())
if(q<256){s=r.r
if(s!=null)if(s.a===1)s.a=3}if((q&4)===0&&(r.e&64)===0)r.c4(r.gcb())},
bL(){return this.bM(null)},
aL(){var s=this,r=s.e
if((r&8)!==0)return
if(r>=256){r=s.e=r-256
if(r<256)if((r&128)!==0&&s.r.c!=null)s.r.bh(s)
else{r=(r&4294967291)>>>0
s.e=r
if((r&64)===0)s.c4(s.gcc())}}},
p(){var s=this,r=(s.e&4294967279)>>>0
s.e=r
if((r&8)===0)s.bY()
r=s.f
return r==null?$.cn():r},
bY(){var s,r=this,q=r.e=(r.e|8)>>>0
if((q&128)!==0){s=r.r
if(s.a===1)s.a=3}if((q&64)===0)r.r=null
r.f=r.ca()},
av(a){var s=this.e
if((s&8)!==0)return
if(s<64)this.ac(a)
else this.au(new A.aY(a))},
aR(a,b){var s
if(t.C.b(a))A.ev(a,b)
s=this.e
if((s&8)!==0)return
if(s<64)this.b_(a,b)
else this.au(new A.d9(a,b))},
d_(){var s=this,r=s.e
if((r&8)!==0)return
r=(r|2)>>>0
s.e=r
if(r<64)s.aZ()
else s.au(B.k)},
aB(){},
aC(){},
ca(){return null},
au(a){var s,r=this,q=r.r
if(q==null)q=r.r=new A.dp()
q.E(0,a)
s=r.e
if((s&128)===0){s=(s|128)>>>0
r.e=s
if(s<256)q.bh(r)}},
ac(a){var s=this,r=s.e
s.e=(r|64)>>>0
s.d.be(s.a,a,A.A(s).h("ad.T"))
s.e=(s.e&4294967231)>>>0
s.bZ((r&4)!==0)},
b_(a,b){var s,r=this,q=r.e,p=new A.iG(r,a,b)
if((q&1)!==0){r.e=(q|16)>>>0
r.bY()
s=r.f
if(s!=null&&s!==$.cn())s.J(p)
else p.$0()}else{p.$0()
r.bZ((q&4)!==0)}},
aZ(){var s,r=this,q=new A.iF(r)
r.bY()
r.e=(r.e|16)>>>0
s=r.f
if(s!=null&&s!==$.cn())s.J(q)
else q.$0()},
c4(a){var s=this,r=s.e
s.e=(r|64)>>>0
a.$0()
s.e=(s.e&4294967231)>>>0
s.bZ((r&4)!==0)},
bZ(a){var s,r,q=this,p=q.e
if((p&128)!==0&&q.r.c==null){p=q.e=(p&4294967167)>>>0
s=!1
if((p&4)!==0)if(p<256){s=q.r
s=s==null?null:s.c==null
s=s!==!1}if(s){p=(p&4294967291)>>>0
q.e=p}}for(;;a=r){if((p&8)!==0){q.r=null
return}r=(p&4)!==0
if(a===r)break
q.e=(p^64)>>>0
if(r)q.aB()
else q.aC()
p=(q.e&4294967231)>>>0
q.e=p}if((p&128)!==0&&p<256)q.r.bh(q)},
$iai:1}
A.iG.prototype={
$0(){var s,r,q,p=this.a,o=p.e
if((o&8)!==0&&(o&16)===0)return
p.e=(o|64)>>>0
s=p.b
o=this.b
r=t.K
q=p.d
if(t.da.b(s))q.e4(s,o,this.c,r,t.l)
else q.be(s,o,r)
p.e=(p.e&4294967231)>>>0},
$S:0}
A.iF.prototype={
$0(){var s=this.a,r=s.e
if((r&16)===0)return
s.e=(r|74)>>>0
s.d.bN(s.c)
s.e=(s.e&4294967231)>>>0},
$S:0}
A.dv.prototype={
I(a,b,c,d){return this.a.dv(a,d,c,b===!0)},
b8(a,b,c){return this.I(a,null,b,c)}}
A.eI.prototype={
gaj(){return this.a},
saj(a){return this.a=a}}
A.aY.prototype={
cB(a){a.ac(this.b)}}
A.d9.prototype={
cB(a){a.b_(this.b,this.c)}}
A.j5.prototype={
cB(a){a.aZ()},
gaj(){return null},
saj(a){throw A.b(A.x("No events after a done."))}}
A.dp.prototype={
bh(a){var s=this,r=s.a
if(r===1)return
if(r>=1){s.a=1
return}A.qt(new A.jE(s,a))
s.a=1},
E(a,b){var s=this,r=s.c
if(r==null)s.b=s.c=b
else{r.saj(b)
s.c=b}}}
A.jE.prototype={
$0(){var s,r,q=this.a,p=q.a
q.a=0
if(p===3)return
s=q.b
r=s.gaj()
q.b=r
if(r==null)q.c=null
s.cB(this.b)},
$S:0}
A.bv.prototype={
gl(){if(this.c)return this.b
return null},
j(){var s,r=this,q=r.a
if(q!=null){if(r.c){s=new A.k($.l,t.k)
r.b=s
r.c=!1
q.aL()
return s}throw A.b(A.x("Already waiting for next."))}return r.eY()},
eY(){var s,r,q=this,p=q.b
if(p!=null){s=new A.k($.l,t.k)
q.b=s
r=p.I(q.gf0(),!0,q.gf2(),q.gf4())
if(q.b!=null)q.a=r
return s}return $.mO()},
p(){var s=this,r=s.a,q=s.b
s.b=null
if(r!=null){s.a=null
if(!s.c)q.aT(!1)
else s.c=!1
return r.p()}return $.cn()},
f1(a){var s,r,q=this
if(q.a==null)return
s=q.b
q.b=a
q.c=!0
s.aw(!0)
if(q.c){r=q.a
if(r!=null)r.bL()}},
f5(a,b){var s=this,r=s.a,q=s.b
s.b=s.a=null
if(r!=null)q.K(new A.H(a,b))
else q.a3(new A.H(a,b))},
f3(){var s=this,r=s.a,q=s.b
s.b=s.a=null
if(r!=null)q.aU(!1)
else q.cW(!1)}}
A.aI.prototype={
I(a,b,c,d){var s=null,r=new A.dj(s,s,s,s,this.$ti.h("dj<1>"))
r.d=new A.jC(this,r)
return r.dv(a,d,c,b===!0)},
b8(a,b,c){return this.I(a,null,b,c)},
ai(a){return this.I(a,null,null,null)}}
A.jC.prototype={
$0(){this.a.b.$1(this.b)},
$S:0}
A.dj.prototype={
fw(a){var s=this.b
if(s>=4)throw A.b(this.ab())
if((s&1)!==0)this.gP().av(a)},
$ibe:1}
A.kf.prototype={
$0(){return this.a.aw(this.b)},
$S:0}
A.dd.prototype={
I(a,b,c,d){var s=this.$ti,r=$.l,q=b===!0?1:0,p=A.l2(r,a,s.y[1]),o=A.m1(r,d)
s=new A.c7(this,p,o,r.ak(c,t.H),r,q|32,s.h("c7<1,2>"))
s.x=this.a.b8(s.geO(),s.geR(),s.geT())
return s},
b8(a,b,c){return this.I(a,null,b,c)}}
A.c7.prototype={
av(a){if((this.e&2)!==0)return
this.eo(a)},
aR(a,b){if((this.e&2)!==0)return
this.ep(a,b)},
aB(){var s=this.x
if(s!=null)s.bL()},
aC(){var s=this.x
if(s!=null)s.aL()},
ca(){var s=this.x
if(s!=null){this.x=null
return s.p()}return null},
eP(a){this.w.eQ(a,this)},
eU(a,b){this.aR(a,b)},
eS(){this.d_()}}
A.bs.prototype={
eQ(a,b){var s,r,q,p,o,n,m=null
try{m=this.b.$1(a)}catch(q){s=A.R(q)
r=A.Q(q)
p=s
o=r
n=A.f6(p,o)
if(n!=null){p=n.a
o=n.b}b.aR(p,o)
return}b.av(m)}}
A.k9.prototype={}
A.kb.prototype={}
A.ka.prototype={}
A.k7.prototype={}
A.k8.prototype={}
A.k6.prototype={}
A.k3.prototype={}
A.f4.prototype={}
A.k2.prototype={}
A.k1.prototype={}
A.k5.prototype={}
A.k4.prototype={}
A.f3.prototype={
hc(a,b,c,d,e){return this.b.$5(a,b,c,d,e)}}
A.kc.prototype={}
A.f2.prototype={
aW(a,b,c){var s,r,q,p,o,n,m=this.gc6(),l=m.a
if(l===B.a){A.dH(b,c)
return}o=l.ge_()
o.toString
s=o
r=$.l
try{$.l=s
m.hc(l,l.gN(),a,b,c)
$.l=r}catch(n){q=A.R(n)
p=A.Q(n)
$.l=r
o=b===q?c:p
s.aW(l,q,o)}},
$in:1}
A.eF.prototype={
gd6(){var s=this.ax
return s==null?this.ax=new A.cf(this):s},
gN(){return this.ay.gd6()},
ga_(){return this.as.a},
bN(a){var s,r,q
try{this.al(a,t.H)}catch(q){s=A.R(q)
r=A.Q(q)
this.aW(this,s,r)}},
be(a,b,c){var s,r,q
try{this.bd(a,b,t.H,c)}catch(q){s=A.R(q)
r=A.Q(q)
this.aW(this,s,r)}},
e4(a,b,c,d,e){var s,r,q
try{this.cD(a,b,c,t.H,d,e)}catch(q){s=A.R(q)
r=A.Q(q)
this.aW(this,s,r)}},
co(a,b){return new A.j2(this,this.ak(a,b),b)},
bo(a){return new A.j1(this,this.ak(a,t.H))},
cp(a,b){return new A.j3(this,this.aK(a,t.H,b),b)},
aI(a,b){this.aW(this,a,b)},
dV(a,b){var s=this.Q,r=s.a
return s.b.$5(r,r.gN(),this,a,b)},
al(a,b){var s=this.a,r=s.a
return s.b.$1$4(r,r.gN(),this,a,b)},
bd(a,b,c,d){var s=this.b,r=s.a
return s.b.$2$5(r,r.gN(),this,a,b,c,d)},
cD(a,b,c,d,e,f){var s=this.c,r=s.a
return s.b.$3$6(r,r.gN(),this,a,b,c,d,e,f)},
ak(a,b){var s=this.d,r=s.a
return s.b.$1$4(r,r.gN(),this,a,b)},
aK(a,b,c){var s=this.e,r=s.a
return s.b.$2$4(r,r.gN(),this,a,b,c)},
bb(a,b,c,d){var s=this.f,r=s.a
return s.b.$3$4(r,r.gN(),this,a,b,c,d)},
dQ(a,b){var s=this.r,r=s.a
if(r===B.a)return null
return s.b.$5(r,r.gN(),this,a,b)},
a9(a){var s=this.w,r=s.a
return s.b.$4(r,r.gN(),this,a)},
gdr(){return this.a},
gdt(){return this.b},
gds(){return this.c},
gdm(){return this.d},
gdn(){return this.e},
gdl(){return this.f},
gd8(){return this.r},
gcg(){return this.w},
gd4(){return this.x},
gd3(){return this.y},
gdk(){return this.z},
gda(){return this.Q},
gc6(){return this.as},
gdD(){return this.at},
ge_(){return this.ay}}
A.j2.prototype={
$0(){return this.a.al(this.b,this.c)},
$S(){return this.c.h("0()")}}
A.j1.prototype={
$0(){return this.a.bN(this.b)},
$S:0}
A.j3.prototype={
$1(a){return this.a.be(this.b,a,this.c)},
$S(){return this.c.h("~(0)")}}
A.eV.prototype={
gdr(){return B.aI},
gdt(){return B.aH},
gds(){return B.aG},
gdm(){return B.aE},
gdn(){return B.aF},
gdl(){return B.aD},
gd8(){return B.az},
gcg(){return B.aJ},
gd4(){return B.T},
gd3(){return B.S},
gdk(){return B.aC},
gda(){return B.aA},
gc6(){return B.aB},
gdD(){return B.U},
ge_(){return null},
gd6(){var s=$.jG
return s==null?$.jG=new A.cf(this):s},
gN(){var s=$.jG
return s==null?$.jG=new A.cf(this):s},
ga_(){return this},
bN(a){var s,r,q
try{if(B.a===$.l){a.$0()
return}A.kl(null,null,this,a)}catch(q){s=A.R(q)
r=A.Q(q)
A.dH(s,r)}},
be(a,b){var s,r,q
try{if(B.a===$.l){a.$1(b)
return}A.km(null,null,this,a,b)}catch(q){s=A.R(q)
r=A.Q(q)
A.dH(s,r)}},
e4(a,b,c){var s,r,q
try{if(B.a===$.l){a.$2(b,c)
return}A.lb(null,null,this,a,b,c)}catch(q){s=A.R(q)
r=A.Q(q)
A.dH(s,r)}},
co(a,b){return new A.jI(this,a,b)},
bo(a){return new A.jH(this,a)},
cp(a,b){return new A.jJ(this,a,b)},
aI(a,b){A.dH(a,b)},
dV(a,b){return A.mp(null,null,this,a,b)},
al(a){if($.l===B.a)return a.$0()
return A.kl(null,null,this,a)},
bd(a,b){if($.l===B.a)return a.$1(b)
return A.km(null,null,this,a,b)},
cD(a,b,c){if($.l===B.a)return a.$2(b,c)
return A.lb(null,null,this,a,b,c)},
ak(a){return a},
aK(a){return a},
bb(a){return a},
dQ(a,b){return null},
a9(a){A.kn(null,null,this,a)}}
A.jI.prototype={
$0(){return this.a.al(this.b,this.c)},
$S(){return this.c.h("0()")}}
A.jH.prototype={
$0(){return this.a.bN(this.b)},
$S:0}
A.jJ.prototype={
$1(a){return this.a.be(this.b,a,this.c)},
$S(){return this.c.h("~(0)")}}
A.cf.prototype={$iG:1}
A.kk.prototype={
$0(){A.nx(this.a,this.b)},
$S:0}
A.d6.prototype={}
A.di.prototype={
gt(a){var s=this,r=new A.c9(s,s.r,s.$ti.h("c9<1>"))
r.c=s.e
return r},
gk(a){return this.a},
dK(a,b){var s,r
if(b!=="__proto__"){s=this.b
if(s==null)return!1
return s[b]!=null}else{r=this.eG(b)
return r}},
eG(a){var s=this.d
if(s==null)return!1
return this.c3(s[B.h.gv(a)&1073741823],a)>=0},
E(a,b){var s,r,q=this
if(typeof b=="string"&&b!=="__proto__"){s=q.b
return q.cV(s==null?q.b=A.l3():s,b)}else if(typeof b=="number"&&(b&1073741823)===b){r=q.c
return q.cV(r==null?q.c=A.l3():r,b)}else return q.eA(b)},
eA(a){var s,r,q=this,p=q.d
if(p==null)p=q.d=A.l3()
s=J.a8(a)&1073741823
r=p[s]
if(r==null)p[s]=[q.c9(a)]
else{if(q.c3(r,a)>=0)return!1
r.push(q.c9(a))}return!0},
u(a,b){var s=this
if(typeof b=="string"&&b!=="__proto__")return s.d0(s.b,b)
else if(typeof b=="number"&&(b&1073741823)===b)return s.d0(s.c,b)
else return s.cf(b)},
cf(a){var s,r,q,p,o=this.d
if(o==null)return!1
s=J.a8(a)&1073741823
r=o[s]
q=this.c3(r,a)
if(q<0)return!1
p=r.splice(q,1)[0]
if(0===r.length)delete o[s]
this.d1(p)
return!0},
V(a){var s=this
if(s.a>0){s.b=s.c=s.d=s.e=s.f=null
s.a=0
s.c7()}},
cV(a,b){if(a[b]!=null)return!1
a[b]=this.c9(b)
return!0},
d0(a,b){var s
if(a==null)return!1
s=a[b]
if(s==null)return!1
this.d1(s)
delete a[b]
return!0},
c7(){this.r=this.r+1&1073741823},
c9(a){var s,r=this,q=new A.jB(a)
if(r.e==null)r.e=r.f=q
else{s=r.f
s.toString
q.c=s
r.f=s.b=q}++r.a
r.c7()
return q},
d1(a){var s=this,r=a.c,q=a.b
if(r==null)s.e=q
else r.b=q
if(q==null)s.f=r
else q.c=r;--s.a
s.c7()},
c3(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.N(a[r].a,b))return r
return-1}}
A.jB.prototype={}
A.c9.prototype={
gl(){var s=this.d
return s==null?this.$ti.c.a(s):s},
j(){var s=this,r=s.c,q=s.a
if(s.b!==q.r)throw A.b(A.a5(q))
else if(r==null){s.d=null
return!1}else{s.d=r.a
s.c=r.b
return!0}}}
A.bc.prototype={
gt(a){var s=this
return new A.eQ(s,s.a,s.c,s.$ti.h("eQ<1>"))},
gk(a){return this.b},
V(a){var s,r,q,p=this;++p.a
if(p.b===0)return
s=p.c
s.toString
r=s
do{q=r.b
q.toString
r.b=r.c=r.a=null
if(q!==s){r=q
continue}else break}while(!0)
p.c=null
p.b=0},
ga6(a){var s
if(this.b===0)throw A.b(A.x("No such element"))
s=this.c
s.toString
return s},
gcw(a){var s
if(this.b===0)throw A.b(A.x("No such element"))
s=this.c.c
s.toString
return s},
gaJ(a){return this.b===0},
bm(a,b,c){var s,r,q=this
if(b.a!=null)throw A.b(A.x("LinkedListEntry is already in a LinkedList"));++q.a
b.a=q
s=q.b
if(s===0){b.b=b
q.c=b.c=b
q.b=s+1
return}r=a.c
r.toString
b.c=r
b.b=a
a.c=r.b=b
q.b=s+1},
cj(a){var s,r,q=this;++q.a
s=a.b
s.c=a.c
a.c.b=s
r=--q.b
a.a=a.b=a.c=null
if(r===0)q.c=null
else if(a===q.c)q.c=s}}
A.eQ.prototype={
gl(){var s=this.c
return s==null?this.$ti.c.a(s):s},
j(){var s=this,r=s.a
if(s.b!==r.a)throw A.b(A.a5(s))
if(r.b!==0)r=s.e&&s.d===r.ga6(0)
else r=!0
if(r){s.c=null
return!1}s.e=!0
r=s.d
s.c=r
s.d=r.b
return!0}}
A.X.prototype={
gba(){var s=this.a
if(s==null||this===s.ga6(0))return null
return this.c}}
A.t.prototype={
gt(a){return new A.bL(a,this.gk(a),A.bE(a).h("bL<t.E>"))},
C(a,b){return this.n(a,b)},
dY(a,b,c){return new A.aD(a,b,A.bE(a).h("@<t.E>").M(c).h("aD<1,2>"))},
S(a,b){return A.i1(a,b,null,A.bE(a).h("t.E"))},
dS(a,b,c,d){var s
A.bQ(b,c,this.gk(a))
for(s=b;s<c;++s)this.q(a,s,d)},
D(a,b,c,d,e){var s,r,q,p
A.bQ(b,c,this.gk(a))
s=c-b
if(s===0)return
A.ah(e,"skipCount")
if(t.j.b(d)){r=e
q=d}else{q=J.kM(d,e).cE(0,!1)
r=0}if(r+s>q.length)throw A.b(A.lF())
if(r<b)for(p=s-1;p>=0;--p)this.q(a,b+p,q[r+p])
else for(p=0;p<s;++p)this.q(a,b+p,q[r+p])},
R(a,b,c,d){return this.D(a,b,c,d,0)},
aO(a,b,c){this.R(a,b,b+c.length,c)},
i(a){return A.hv(a,"[","]")},
$io:1,
$ir:1}
A.cL.prototype={
bv(a,b){var s,r,q,p
for(s=this.gb7(),s=s.gt(s),r=A.A(this).y[1];s.j();){q=s.gl()
p=this.n(0,q)
b.$2(q,p==null?r.a(p):p)}},
gbt(){var s=this.gb7()
return A.nX(s,new A.hA(this),A.A(s).h("q.E"),A.A(this).h("a6<1,2>"))},
gk(a){var s=this.gb7()
return s.gk(s)},
i(a){return A.kU(this)},
$iaS:1}
A.hA.prototype={
$1(a){var s=this.a,r=s.n(0,a)
if(r==null)r=A.A(s).y[1].a(r)
return new A.a6(a,r,A.A(s).h("a6<1,2>"))},
$S(){return A.A(this.a).h("a6<1,2>(1)")}}
A.hB.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.u(a)
r.a=(r.a+=s)+": "
s=A.u(b)
r.a+=s},
$S:36}
A.cJ.prototype={
gt(a){var s=this
return new A.eR(s,s.c,s.d,s.b,s.$ti.h("eR<1>"))},
gaJ(a){return this.b===this.c},
gk(a){return(this.c-this.b&this.a.length-1)>>>0},
C(a,b){var s=this,r=s.gk(0)
if(0>b||b>=r)A.y(A.e9(b,r,s,null,"index"))
r=s.a
r=r[(s.b+b&r.length-1)>>>0]
return r==null?s.$ti.c.a(r):r},
u(a,b){var s,r=this
for(s=r.b;s!==r.c;s=(s+1&r.a.length-1)>>>0)if(J.N(r.a[s],b)){r.cf(s);++r.d
return!0}return!1},
i(a){return A.hv(this,"{","}")},
cf(a){var s,r,q,p=this,o=p.a,n=o.length-1,m=p.b,l=p.c
if((a-m&n)>>>0<(l-a&n)>>>0){for(s=a;s!==m;s=r){r=(s-1&n)>>>0
o[s]=o[r]}o[m]=null
p.b=(m+1&n)>>>0
return(a+1&n)>>>0}else{m=p.c=(l-1&n)>>>0
for(s=a;s!==m;s=q){q=(s+1&n)>>>0
o[s]=o[q]}o[m]=null
return a}}}
A.eR.prototype={
gl(){var s=this.e
return s==null?this.$ti.c.a(s):s},
j(){var s,r=this,q=r.a
if(r.c!==q.d)A.y(A.a5(q))
s=r.d
if(s===r.b){r.e=null
return!1}q=q.a
r.e=q[s]
r.d=(s+1&q.length-1)>>>0
return!0}}
A.bR.prototype={
a4(a,b){var s
for(s=J.ak(b);s.j();)this.E(0,s.gl())},
i(a){return A.hv(this,"{","}")},
S(a,b){return A.lV(this,b,this.$ti.c)},
C(a,b){var s,r,q,p=this
A.ah(b,"index")
s=A.or(p,p.r,p.$ti.c)
for(r=b;s.j();){if(r===0){q=s.d
return q==null?s.$ti.c.a(q):q}--r}throw A.b(A.e9(b,b-r,p,null,"index"))},
$io:1,
$iaT:1}
A.dt.prototype={}
A.jZ.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:true})
return s}catch(r){}return null},
$S:21}
A.jY.prototype={
$0(){var s,r
try{s=new TextDecoder("utf-8",{fatal:false})
return s}catch(r){}return null},
$S:21}
A.dV.prototype={}
A.dX.prototype={}
A.hd.prototype={}
A.ie.prototype={
dO(a){return new A.cd(!1).bk(a,0,null,!0)}}
A.ig.prototype={
ag(a){var s,r,q,p=A.bQ(0,null,a.length)
if(p===0)return new Uint8Array(0)
s=p*3
r=new Uint8Array(s)
q=new A.k_(r)
if(q.eL(a,0,p)!==p)q.cm()
return new Uint8Array(r.subarray(0,A.p3(0,q.b,s)))}}
A.k_.prototype={
cm(){var s=this,r=s.c,q=s.b,p=s.b=q+1
r.$flags&2&&A.E(r)
r[q]=239
q=s.b=p+1
r[p]=191
s.b=q+1
r[q]=189},
fq(a,b){var s,r,q,p,o=this
if((b&64512)===56320){s=65536+((a&1023)<<10)|b&1023
r=o.c
q=o.b
p=o.b=q+1
r.$flags&2&&A.E(r)
r[q]=s>>>18|240
q=o.b=p+1
r[p]=s>>>12&63|128
p=o.b=q+1
r[q]=s>>>6&63|128
o.b=p+1
r[p]=s&63|128
return!0}else{o.cm()
return!1}},
eL(a,b,c){var s,r,q,p,o,n,m,l,k=this
if(b!==c&&(a.charCodeAt(c-1)&64512)===55296)--c
for(s=k.c,r=s.$flags|0,q=s.length,p=b;p<c;++p){o=a.charCodeAt(p)
if(o<=127){n=k.b
if(n>=q)break
k.b=n+1
r&2&&A.E(s)
s[n]=o}else{n=o&64512
if(n===55296){if(k.b+4>q)break
m=p+1
if(k.fq(o,a.charCodeAt(m)))p=m}else if(n===56320){if(k.b+3>q)break
k.cm()}else if(o<=2047){n=k.b
l=n+1
if(l>=q)break
k.b=l
r&2&&A.E(s)
s[n]=o>>>6|192
k.b=l+1
s[l]=o&63|128}else{n=k.b
if(n+2>=q)break
l=k.b=n+1
r&2&&A.E(s)
s[n]=o>>>12|224
n=k.b=l+1
s[l]=o>>>6&63|128
k.b=n+1
s[n]=o&63|128}}}return p}}
A.cd.prototype={
bk(a,b,c,d){var s,r,q,p,o,n,m=this,l=A.bQ(b,c,a.length)
if(b===l)return""
if(a instanceof Uint8Array){s=a
r=s
q=0}else{r=A.oM(a,b,l)
l-=b
q=b
b=0}if(l-b>=15){p=m.a
o=A.oL(p,r,b,l)
if(o!=null){if(!p)return o
if(o.indexOf("\ufffd")<0)return o}}o=m.c0(r,b,l,!0)
p=m.b
if((p&1)!==0){n=A.oN(p)
m.b=0
throw A.b(A.nD(n,a,q+m.c))}return o},
c0(a,b,c,d){var s,r,q=this
if(c-b>1000){s=B.b.U(b+c,2)
r=q.c0(a,b,s,!1)
if((q.b&1)!==0)return r
return r+q.c0(a,s,c,d)}return q.fE(a,b,c,d)},
fE(a,b,c,d){var s,r,q,p,o,n,m,l=this,k=65533,j=l.b,i=l.c,h=new A.cZ(""),g=b+1,f=a[b]
A:for(s=l.a;;){for(;;g=p){r="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHIHHHJEEBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBKCCCCCCCCCCCCDCLONNNMEEEEEEEEEEE".charCodeAt(f)&31
i=j<=32?f&61694>>>r:(f&63|i<<6)>>>0
j=" \x000:XECCCCCN:lDb \x000:XECCCCCNvlDb \x000:XECCCCCN:lDb AAAAA\x00\x00\x00\x00\x00AAAAA00000AAAAA:::::AAAAAGG000AAAAA00KKKAAAAAG::::AAAAA:IIIIAAAAA000\x800AAAAA\x00\x00\x00\x00 AAAAA".charCodeAt(j+r)
if(j===0){q=A.bh(i)
h.a+=q
if(g===c)break A
break}else if((j&1)!==0){if(s)switch(j){case 69:case 67:q=A.bh(k)
h.a+=q
break
case 65:q=A.bh(k)
h.a+=q;--g
break
default:q=A.bh(k)
h.a=(h.a+=q)+q
break}else{l.b=j
l.c=g-1
return""}j=0}if(g===c)break A
p=g+1
f=a[g]}p=g+1
f=a[g]
if(f<128){for(;;){if(!(p<c)){o=c
break}n=p+1
f=a[p]
if(f>=128){o=n-1
p=n
break}p=n}if(o-g<20)for(m=g;m<o;++m){q=A.bh(a[m])
h.a+=q}else{q=A.o8(a,g,o)
h.a+=q}if(o===c)break A
g=p}else g=p}if(d&&j>32)if(s){s=A.bh(k)
h.a+=s}else{l.b=77
l.c=c
return""}l.b=j
l.c=i
s=h.a
return s.charCodeAt(0)==0?s:s}}
A.eK.prototype={
dG(a,b,c){var s=this.a
if(s!=null)s.register(a,b,c)},
dP(a){var s=this.a
if(s!=null)s.unregister(a)}}
A.e1.prototype={
X(a,b){var s
if(b==null)return!1
s=!1
if(b instanceof A.e1)if(this.a===b.a)s=this.b===b.b
return s},
gv(a){return A.kV(this.a,this.b,B.f,B.f)},
ae(a,b){var s=B.b.ae(this.a,b.a)
if(s!==0)return s
return B.b.ae(this.b,b.b)},
i(a){var s=this,r=A.ns(A.lQ(s)),q=A.e2(A.lO(s)),p=A.e2(A.lL(s)),o=A.e2(A.lM(s)),n=A.e2(A.lN(s)),m=A.e2(A.lP(s)),l=A.lx(A.o0(s)),k=s.b,j=k===0?"":A.lx(k)
return r+"-"+q+"-"+p+" "+o+":"+n+":"+m+"."+l+j}}
A.az.prototype={
X(a,b){if(b==null)return!1
return b instanceof A.az&&this.a===b.a},
gv(a){return B.b.gv(this.a)},
ae(a,b){return B.b.ae(this.a,b.a)},
i(a){var s,r,q,p,o,n=this.a,m=B.b.U(n,36e8),l=n%36e8
if(n<0){m=0-m
n=0-l
s="-"}else{n=l
s=""}r=B.b.U(n,6e7)
n%=6e7
q=r<10?"0":""
p=B.b.U(n,1e6)
o=p<10?"0":""
return s+m+":"+q+r+":"+o+p+"."+B.h.hM(B.b.i(n%1e6),6,"0")}}
A.j6.prototype={
i(a){return this.Y()}}
A.F.prototype={
gaa(){return A.o_(this)}}
A.dN.prototype={
i(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.hf(s)
return"Assertion failed"}}
A.aG.prototype={}
A.al.prototype={
gc2(){return"Invalid argument"+(!this.a?"(s)":"")},
gc1(){return""},
i(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+A.u(p),n=s.gc2()+q+o
if(!s.a)return n
return n+s.gc1()+": "+A.hf(s.gcu())},
gcu(){return this.b}}
A.bP.prototype={
gcu(){return this.b},
gc2(){return"RangeError"},
gc1(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.u(q):""
else if(q==null)s=": Not greater than or equal to "+A.u(r)
else if(q>r)s=": Not in inclusive range "+A.u(r)+".."+A.u(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.u(r)
return s}}
A.cD.prototype={
gcu(){return this.b},
gc2(){return"RangeError"},
gc1(){if(this.b<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gk(a){return this.f}}
A.d1.prototype={
i(a){return"Unsupported operation: "+this.a}}
A.eB.prototype={
i(a){var s=this.a
return s!=null?"UnimplementedError: "+s:"UnimplementedError"}}
A.as.prototype={
i(a){return"Bad state: "+this.a}}
A.dW.prototype={
i(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.hf(s)+"."}}
A.es.prototype={
i(a){return"Out of Memory"},
gaa(){return null},
$iF:1}
A.cY.prototype={
i(a){return"Stack Overflow"},
gaa(){return null},
$iF:1}
A.j9.prototype={
i(a){return"Exception: "+this.a}}
A.hh.prototype={
i(a){var s,r,q,p,o,n,m,l,k,j,i,h=this.a,g=""!==h?"FormatException: "+h:"FormatException",f=this.c,e=this.b
if(typeof e=="string"){if(f!=null)s=f<0||f>e.length
else s=!1
if(s)f=null
if(f==null){if(e.length>78)e=B.h.cR(e,0,75)+"..."
return g+"\n"+e}for(r=1,q=0,p=!1,o=0;o<f;++o){n=e.charCodeAt(o)
if(n===10){if(q!==o||!p)++r
q=o+1
p=!1}else if(n===13){++r
q=o+1
p=!0}}g=r>1?g+(" (at line "+r+", character "+(f-q+1)+")\n"):g+(" (at character "+(f+1)+")\n")
m=e.length
for(o=f;o<m;++o){n=e.charCodeAt(o)
if(n===10||n===13){m=o
break}}l=""
if(m-q>78){k="..."
if(f-q<75){j=q+75
i=q}else{if(m-f<75){i=m-75
j=m
k=""}else{i=f-36
j=f+36}l="..."}}else{j=m
i=q
k=""}return g+l+B.h.cR(e,i,j)+k+"\n"+B.h.cO(" ",f-i+l.length)+"^\n"}else return f!=null?g+(" (at offset "+A.u(f)+")"):g}}
A.q.prototype={
cE(a,b){var s=A.A(this).h("q.E")
if(b)s=A.cK(this,s)
else{s=A.cK(this,s)
s.$flags=1
s=s}return s},
gk(a){var s,r=this.gt(this)
for(s=0;r.j();)++s
return s},
S(a,b){return A.lV(this,b,A.A(this).h("q.E"))},
ga6(a){var s=this.gt(this)
if(!s.j())throw A.b(A.ec())
return s.gl()},
C(a,b){var s,r
A.ah(b,"index")
s=this.gt(this)
for(r=b;s.j();){if(r===0)return s.gl();--r}throw A.b(A.e9(b,b-r,this,null,"index"))},
i(a){return A.nJ(this,"(",")")}}
A.a6.prototype={
i(a){return"MapEntry("+A.u(this.a)+": "+A.u(this.b)+")"}}
A.z.prototype={
gv(a){return A.d.prototype.gv.call(this,0)},
i(a){return"null"}}
A.d.prototype={$id:1,
X(a,b){return this===b},
gv(a){return A.cT(this)},
i(a){return"Instance of '"+A.eu(this)+"'"},
gA(a){return A.qe(this)},
toString(){return this.i(this)}}
A.eY.prototype={
i(a){return""},
$iJ:1}
A.cZ.prototype={
gk(a){return this.a.length},
i(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.e4.prototype={
q(a,b,c){this.a.set(b,c)},
i(a){return"Expando:null"}}
A.hF.prototype={
i(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.hm.prototype={
$2(a,b){this.a.am(new A.hk(a),new A.hl(b),t.X)},
$S:41}
A.hk.prototype={
$1(a){var s=this.a
return s.call(s)},
$S:46}
A.hl.prototype={
$2(a,b){var s,r,q=t.g.a(v.G.Error),p=A.q5(q,["Dart exception thrown from converted Future. Use the properties 'error' to fetch the boxed error and 'stack' to recover the stack trace."])
if(t.aX.b(a))A.y("Attempting to box non-Dart object.")
s={}
s[$.n3()]=a
p.error=s
p.stack=b.i(0)
r=this.a
r.call(r,p)},
$S:11}
A.kD.prototype={
$1(a){return this.a.B(a)},
$S:9}
A.kE.prototype={
$1(a){if(a==null)return this.a.H(new A.hF(a===undefined))
return this.a.H(a)},
$S:9}
A.jy.prototype={
bJ(a){if(a<=0||a>4294967296)throw A.b(A.lS(u.g+a))
return Math.random()*a>>>0}}
A.jz.prototype={
ew(){var s=self.crypto
if(s!=null)if(s.getRandomValues!=null)return
throw A.b(A.bk("No source of cryptographically secure random numbers available."))},
bJ(a){var s,r,q,p,o,n,m,l
if(a<=0||a>4294967296)throw A.b(A.lS(u.g+a))
if(a>255)if(a>65535)s=a>16777215?4:3
else s=2
else s=1
r=this.a
r.$flags&2&&A.E(r,11)
r.setUint32(0,0,!1)
q=4-s
p=A.Y(Math.pow(256,s))
for(o=a-1,n=(a&o)===0;;){crypto.getRandomValues(J.co(B.ae.ga5(r),q,s))
m=r.getUint32(0,!1)
if(n)return(m&o)>>>0
l=m%a
if(m-l+a<p)return l}}}
A.cX.prototype={
Y(){return"SqliteUpdateKind."+this.b}}
A.an.prototype={
gv(a){return A.kV(this.a,this.b,this.c,B.f)},
X(a,b){if(b==null)return!1
return b instanceof A.an&&b.a===this.a&&b.b===this.b&&b.c===this.c},
i(a){return"SqliteUpdate: "+this.a.i(0)+" on "+this.b+", rowid = "+this.c}}
A.bT.prototype={
i(a){var s,r,q=this,p=q.e
p=p==null?"":"while "+p+", "
p="SqliteException("+q.c+"): "+p+q.a
s=q.b
if(s!=null)p=p+", "+s
s=q.f
if(s!=null){r=q.d
r=r!=null?" (at position "+A.u(r)+"): ":": "
s=p+"\n  Causing statement"+r+s
p=q.r
p=p!=null?s+(", parameters: "+J.nc(p,new A.hW(),t.N).hy(0,", ")):s}return p.charCodeAt(0)==0?p:p}}
A.hW.prototype={
$1(a){if(t.p.b(a))return"blob ("+a.length+" bytes)"
else return J.aL(a)},
$S:47}
A.fX.prototype={
dC(){var s=this,r=s.d
return r==null?s.d=new A.aZ(s,A.v([],t.fS),new A.h5(s),new A.h6(s),t.fs):r},
ff(){var s=this,r=s.e
return r==null?s.e=new A.aZ(s,A.v([],t.e),new A.h2(s),new A.h3(s),t.bq):r},
c_(){var s=this,r=s.f
return r==null?s.f=new A.aZ(s,A.v([],t.e),new A.fZ(s),new A.h_(s),t.fK):r},
m(){var s,r,q,p=this
if(p.r)return
p.r=!0
s=p.d
if(s!=null)s.m()
s=p.f
if(s!=null)s.m()
s=p.e
if(s!=null)s.m()
s=p.b
r=s.cP()
q=r!==0?A.lf(p.a,s,r,"closing database",null,null):null
if(q!=null)throw A.b(q)},
h6(a,b){var s,r,q
if(this.r)A.y(A.x("This database has already been closed"))
s=this.b
r=s.a
q=r.b1(B.e.ag(a),1)
r=r.d
s=A.my(r,"sqlite3_exec",[s.b,q,0,0,0])
r.dart_sqlite3_free(q)
if(s!==0)A.lk(this,s,"executing",a,b)},
gb2(){if(this.r)A.y(A.x("This database has already been closed"))
var s=this.b
return s.a.d.sqlite3_get_autocommit(s.b)!==0},
f8(a,b,c,d,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e=this
if(e.r)A.y(A.x("This database has already been closed"))
s=B.e.ag(a)
r=e.b
q=r.a
p=q.cn(s)
o=q.bH(4)
n=q.bH(4)
m=new A.iu(r,p,o,n)
l=A.v([],t.bb)
k=new A.h0(m,l)
for(r=s.length,q=q.b,j=0;j<r;j=g){i=m.cQ(j,r-j,0)
o=i.b
if(o!==0){k.$0()
A.lk(e,o,"preparing statement",a,null)}o=q.buffer
h=B.b.U(o.byteLength,4)
g=new Int32Array(o,0,h)[B.b.G(n,2)]-p
f=i.a
if(f!=null)l.push(new A.bU(f,e,new A.cd(!1).bk(s,j,g,!0)))
if(l.length===c){j=g
break}}if(b)while(j<r){i=m.cQ(j,r-j,0)
o=q.buffer
h=B.b.U(o.byteLength,4)
j=new Int32Array(o,0,h)[B.b.G(n,2)]-p
f=i.a
if(f!=null){l.push(new A.bU(f,e,""))
k.$0()
throw A.b(A.b4(a,"sql","Had an unexpected trailing statement."))}else if(i.b!==0){k.$0()
throw A.b(A.b4(a,"sql","Has trailing data after the first sql statement:"))}}m.m()
return l},
e0(a,b){var s=this.f8(a,b,1,!1,!0)
if(s.length===0)throw A.b(A.b4(a,"sql","Must contain an SQL statement."))
return B.c.ga6(s)},
hN(a){return this.e0(a,!1)}}
A.h5.prototype={
$0(){var s=this.a,r=s.b
r.a.dN(r.b,new A.h4(s))},
$S:0}
A.h4.prototype={
$3(a,b,c){var s=A.o7(a)
if(s==null)return
this.a.d.cq(new A.an(s,b,c))},
$S:49}
A.h6.prototype={
$0(){var s=this.a.b
s.a.dN(s.b,null)
return null},
$S:0}
A.h2.prototype={
$0(){var s=this.a,r=s.b
r.a.dM(r.b,new A.h1(s))
return null},
$S:0}
A.h1.prototype={
$0(){this.a.e.cq(null)},
$S:0}
A.h3.prototype={
$0(){var s=this.a.b
s.a.dM(s.b,null)
return null},
$S:0}
A.fZ.prototype={
$0(){var s=this.a,r=s.b
r.a.dL(r.b,new A.fY(s))
return null},
$S:0}
A.fY.prototype={
$0(){var s=this.a.f
s.cq(null)
return 0},
$S:3}
A.h_.prototype={
$0(){var s=this.a.b
s.a.dL(s.b,null)
return null},
$S:0}
A.h0.prototype={
$0(){var s,r,q,p,o,n
this.a.m()
for(s=this.b,r=s.length,q=0;q<s.length;s.length===r||(0,A.T)(s),++q){p=s[q]
if(!p.r){p.r=!0
if(!p.f){o=p.a
o.c.d.sqlite3_reset(o.b)
p.f=!0}o=p.a
n=o.c
n.d.sqlite3_finalize(o.b)
n=n.w
if(n!=null){n=n.a
if(n!=null)n.unregister(o.d)}}}},
$S:0}
A.aZ.prototype={
gaQ(){var s=this.r
return s==null?this.r=this.dc(!1):s},
dc(a){return new A.aI(new A.jR(this,a),this.$ti.h("aI<1>"))},
cq(a){var s,r,q,p,o,n,m
for(s=this.c,r=s.length,q=0;q<s.length;s.length===r||(0,A.T)(s),++q){p=s[q]
o=p.a
if(p.b){n=o.b
if(n>=4)A.y(o.ab())
if((n&1)!==0)o.gP().av(a)}else{n=o.b
if(n>=4)A.y(o.ab())
if((n&1)!==0)o.ac(a)
else if((n&3)===0){o=o.aV()
n=new A.aY(a)
m=o.c
if(m==null)o.b=o.c=n
else{m.saj(n)
o.c=n}}}}},
m(){var s,r,q,p=this
for(s=p.c,r=s.length,q=0;q<s.length;s.length===r||(0,A.T)(s),++q)s[q].a.m()
p.d=null
if(p.b){p.f.$0()
p.b=!1}}}
A.jR.prototype={
$1(a){var s,r,q=this.a
if(q.a.r){a.m()
return}s=this.b
r=new A.jS(q,a,s)
a.r=a.e=new A.jT(q,a,s)
a.f=r
r.$0()},
$S(){return this.a.$ti.h("~(be<1>)")}}
A.jS.prototype={
$0(){var s=this.a,r=s.c,q=r.length
r.push(new A.ds(this.b,this.c))
if(q===0){if(s.a.r)A.y(A.x("This database has already been closed"))
s.e.$0()
s.b=!0}},
$S:0}
A.jT.prototype={
$0(){var s=this.a,r=s.c
B.c.u(r,new A.ds(this.b,this.c))
r=r.length
if(r===0&&!s.a.r){s.f.$0()
s.b=!1}},
$S:0}
A.hV.prototype={
dX(){var s=null,r=this.a.a.d.sqlite3_initialize()
if(r!==0)throw A.b(A.lW(s,s,r,"Error returned by sqlite3_initialize",s,s,s))},
hJ(a,b){var s,r,q,p,o,n,m,l,k,j,i
this.dX()
switch(2){case 2:break}s=this.a
r=s.a
q=r.b1(B.e.ag(a),1)
p=r.bH(4)
o=r.b1(B.e.ag(b),1)
n=r.d
m=n.sqlite3_open_v2(q,p,6,o)
l=A.aE(r.b.buffer,0,null)[B.b.G(p,2)]
n.dart_sqlite3_free(q)
n.dart_sqlite3_free(p)
n.dart_sqlite3_free(o)
k=new A.d()
j=new A.im(r,l,k)
r=r.r
if(r!=null)r.dG(j,l,k)
if(m!==0){i=A.lf(s,j,m,"opening the database",null,null)
j.cP()
throw A.b(i)}n.sqlite3_extended_result_codes(l,1)
return new A.fX(s,j,!1)}}
A.bU.prototype={
a2(a,b){A.lk(this.b,a,b,this.d,this.e)},
bl(){if(this.r||this.b.r)throw A.b(A.x(u.n))},
d9(){var s,r=this,q=r.f=!1,p=r.a,o=p.b
p=p.c.d
do s=p.sqlite3_step(o)
while(s===100)
r.bc()
if(s!==0?s!==101:q)r.a2(s,"executing statement")},
eC(a){var s
this.bl()
s=this.a
s=s.c.d.sqlite3_bind_parameter_count(s.b)
if(0!==s)A.y(A.b4(a,"parameters","Expected "+A.u(s)+" parameters, got 0"))
return},
cX(a){A:{if(a instanceof A.hu){this.eC(a.a)
break A}if(a instanceof A.cx)a.a.$1(this)}},
bc(){if(!this.f){var s=this.a
s.c.d.sqlite3_reset(s.b)
this.f=!0}},
m(){var s,r,q=this
if(!q.r){q.r=!0
q.bc()
s=q.a
r=s.c
r.d.sqlite3_finalize(s.b)
r=r.w
if(r!=null)r.dP(s.d)}},
h8(a){var s=this
s.bl()
s.bc()
s.cX(a)
s.d9()}}
A.e8.prototype={
bQ(a,b){return this.d.Z(a)?1:0},
cI(a,b){this.d.u(0,a)},
cJ(a){return new v.G.URL(a,"file:///").pathname},
ap(a,b){var s,r=a.a
if(r==null)r=A.lD(this.b,"/")
s=this.d
if(!s.Z(r))if((b&4)!==0)s.q(0,r,new A.at(new Uint8Array(0),0))
else throw A.b(A.bl(14))
return new A.ca(new A.eM(this,r,(b&8)!==0),0)},
cL(a){}}
A.eM.prototype={
e2(a,b){var s,r=this.a.d.n(0,this.b)
if(r==null||r.b<=b)return 0
s=Math.min(a.length,r.b-b)
B.d.R(a,0,s,J.co(B.d.ga5(r.a),b,s))
return s},
cH(){return this.d>=2?1:0},
bR(){if(this.c)this.a.d.u(0,this.b)},
aM(){return this.a.d.n(0,this.b).b},
cK(a){this.d=a},
cM(a){},
bg(a){var s=this.a.d,r=this.b,q=s.n(0,r)
if(q==null){s.q(0,r,new A.at(new Uint8Array(0),0))
s.n(0,r).sk(0,a)}else q.sk(0,a)},
cN(a){this.d=a},
aN(a,b){var s,r=this.a.d,q=this.b,p=r.n(0,q)
if(p==null){p=new A.at(new Uint8Array(0),0)
r.q(0,q,p)}s=b+a.length
if(s>p.b)p.sk(0,s)
p.R(0,b,s,a)}}
A.kC.prototype={
$1(a){return a.length!==0},
$S:68}
A.dS.prototype={}
A.hH.prototype={
Y(){return"OpenMode."+this.b}}
A.b8.prototype={}
A.hu.prototype={}
A.cx.prototype={}
A.aW.prototype={
i(a){return"VfsException("+this.a+")"}}
A.cW.prototype={}
A.U.prototype={}
A.dR.prototype={}
A.dQ.prototype={
gbS(){return 0},
e6(a,b){return 12},
gbU(){return 4096},
bT(a,b){var s=this.e2(a,b),r=a.length
if(s<r){B.d.dS(a,s,r,0)
throw A.b(B.ax)}},
$ia1:1,
$id2:1}
A.bp.prototype={}
A.kH.prototype={
$0(){var s,r,q
for(s=this.a;!s.gaJ(0);){if(s.b===0)A.y(A.x("No such element"))
r=s.c
q=r.a
q.toString
q.cj(A.A(r).h("X.E").a(r))
r.d.$0()}},
$S:0}
A.kF.prototype={
$1(a){var s=this.a,r=s.b
s.bm(s.c,new A.bp(a),!1)
if(r===0)v.G.Promise.resolve().then(this.b)},
$S:7}
A.kG.prototype={
$4(a,b,c,d){this.a.$1(c.bo(d))},
$S:71}
A.is.prototype={}
A.im.prototype={
cP(){var s=this.a,r=s.r
if(r!=null)r.dP(this.c)
return s.d.sqlite3_close_v2(this.b)}}
A.iu.prototype={
m(){var s=this,r=s.a.a.d
r.dart_sqlite3_free(s.b)
r.dart_sqlite3_free(s.c)
r.dart_sqlite3_free(s.d)},
cQ(a,b,c){var s,r,q=this,p=q.a,o=p.a,n=q.c
p=A.my(o.d,"sqlite3_prepare_v3",[p.b,q.b+a,b,c,n,q.d])
s=A.aE(o.b.buffer,0,null)[B.b.G(n,2)]
if(s===0)r=null
else{n=new A.d()
r=new A.it(s,o,n)
o=o.w
if(o!=null)o.dG(r,s,n)}return new A.eU(r,p)}}
A.it.prototype={
ek(a,b,c,d){var s,r
if(d===0)return
s=this.c
r=s.d.sqlite3_column_blob(this.b,a)
B.d.R(b,c,c+d,A.ag(s.b.buffer,r,d))}}
A.bm.prototype={}
A.bn.prototype={}
A.bX.prototype={
n(a,b){A.aE(this.a.b.buffer,0,null)
B.b.G(this.c+b*4,2)
return new A.bn()},
q(a,b,c){throw A.b(A.bk("Setting element in WasmValueList"))},
gk(a){return this.b}}
A.dZ.prototype={
hF(a){var s,r,q=this.b
q===$&&A.M()
s="[sqlite3] "+A.bY(q,a,null)
r=$.pv
if(r==null)A.mH(s)
else r.$1(s)},
hD(a,b){var s,r,q,p=A.Y(v.G.Number(a))*1000
if(p<-864e13||p>864e13)A.y(A.ac(p,-864e13,864e13,"millisecondsSinceEpoch",null))
A.dJ(!1,"isUtc",t.y)
s=new A.e1(p,0,!1)
r=this.b
r===$&&A.M()
q=A.nY(r.buffer,b,8)
q.$flags&2&&A.E(q)
q[0]=A.lP(s)
q[1]=A.lN(s)
q[2]=A.lM(s)
q[3]=A.lL(s)
q[4]=A.lO(s)-1
q[5]=A.lQ(s)-1900
q[6]=B.b.bV(A.o1(s),7)},
ik(a,b,c,d,e){var s,r,q,p,o,n,m,l,k,j=null
try{p=this.b
p===$&&A.M()
s=new A.cW(A.l0(p,b,j))
r=a.ap(s,d)
if(e!==0){o=r.b
n=A.aE(p.buffer,0,j)
m=B.b.G(e,2)
n.$flags&2&&A.E(n)
n[m]=o}p=A.aE(p.buffer,0,j)
o=B.b.G(c,2)
p.$flags&2&&A.E(p)
p[o]=0
l=r.a
return l}catch(k){p=A.R(k)
if(p instanceof A.aW){q=p
p=this.b
p===$&&A.M()
o=q.a
p=A.aE(p.buffer,0,j)
n=B.b.G(c,2)
p.$flags&2&&A.E(p)
p[n]=o}else{p=this.b
p===$&&A.M()
p=p.buffer
p=A.aE(p,0,j)
o=B.b.G(c,2)
p.$flags&2&&A.E(p)
p[o]=1}}return j},
i5(a,b,c){return A.a4(new A.fH(this,b,a,c))},
hY(a,b,c,d){return A.a4(new A.fD(this,b,a,c,d))},
ig(a,b,c,d){return A.a4(new A.fM(this,b,a,c,d))},
im(a,b,c){return A.a4(new A.fO(this,c,b,a))},
is(a,b){return A.a4(new A.fR(a,b))},
i3(a,b){return A.a4(new A.fG(this,a,b))},
i1(a){return A.a4(new A.fF(a))},
ip(a,b,c,d){return A.a4(new A.fP(this,a,b,c,d))},
iA(a,b,c,d){return A.a4(new A.fV(this,a,b,c,d))},
iw(a,b){return A.a4(new A.fT(a,b))},
iu(a,b){return A.a4(new A.fS(a,b))},
ia(a,b){return A.a4(new A.fL(this,a,b))},
ic(a,b){return A.a4(new A.fK(this,a,b))},
ii(a,b){return A.a4(new A.fN(a,b))},
iy(a,b){return A.a4(new A.fU(a,b))},
i_(a,b){return A.a4(new A.fE(this,a,b))},
i6(a){return A.aJ(new A.fI(a),0)},
i8(a,b,c){return A.aJ(new A.fJ(a,b,c),10)},
iq(a){return A.aJ(new A.fQ(a),4096)},
fS(a){A.aJ(a,null)},
fN(a){return A.aJ(a,1)},
fQ(a,b,c,d,e){A.aJ(new A.fB(this,d,a,b,e),null)},
fY(a,b,c,d){var s=a.giL(),r=this.a
r===$&&A.M()
s.$2(new A.bm(),new A.bX(r,c,d))},
h1(a,b,c,d){var s=a.giN(),r=this.a
r===$&&A.M()
s.$2(new A.bm(),new A.bX(r,c,d))},
h_(a,b,c,d){var s=a.giM(),r=this.a
r===$&&A.M()
s.$2(new A.bm(),new A.bX(r,c,d))},
h3(a,b){var s=a.giO()
this.a===$&&A.M()
s.$1(new A.bm())},
fW(a,b){var s=a.giK()
this.a===$&&A.M()
s.$1(new A.bm())},
fU(a,b,c,d,e){return A.aJ(new A.fC(this,c,b,e,d,a),0)},
fL(a,b){return A.aJ(new A.fA(a,b),0)},
fJ(a,b){return A.aJ(new A.fz(a,b),1)},
fH(a,b,c){return A.aJ(new A.fy(a,b,c),2)}}
A.fH.prototype={
$0(){var s=this,r=s.a.b
r===$&&A.M()
s.c.cI(A.bY(r,s.b,null),s.d)},
$S:0}
A.fD.prototype={
$0(){var s,r,q=this,p=q.a.b
p===$&&A.M()
s=q.c.bQ(A.bY(p,q.b,null),q.d)
p=A.aE(p.buffer,0,null)
r=B.b.G(q.e,2)
p.$flags&2&&A.E(p)
p[r]=s},
$S:0}
A.fM.prototype={
$0(){var s,r,q,p=this,o=p.a.b
o===$&&A.M()
s=B.e.ag(p.c.cJ(A.bY(o,p.b,null)))
r=s.length
if(r>=p.d)throw A.b(A.bl(14))
o=A.ag(o.buffer,0,null)
q=p.e
B.d.aO(o,q,s)
o.$flags&2&&A.E(o)
o[q+r]=0},
$S:0}
A.fO.prototype={
$0(){var s,r=this,q=r.a.b
q===$&&A.M()
s=A.ag(q.buffer,r.b,r.c)
q=r.d
if(q!=null)A.lo(s,q.b)
else return A.lo(s,null)},
$S:0}
A.fR.prototype={
$0(){this.a.cL(new A.az(this.b))},
$S:0}
A.fG.prototype={
$0(){var s,r=Date.now(),q=this.a.b
q===$&&A.M()
s=v.G.BigInt(r)
A.lJ(A.lI(q.buffer,0,null),this.c,s,!0)},
$S:0}
A.fF.prototype={
$0(){return this.a.bR()},
$S:0}
A.fP.prototype={
$0(){var s=this,r=s.a.b
r===$&&A.M()
s.b.bT(A.ag(r.buffer,s.c,s.d),A.Y(v.G.Number(s.e)))},
$S:0}
A.fV.prototype={
$0(){var s=this,r=s.a.b
r===$&&A.M()
s.b.aN(A.ag(r.buffer,s.c,s.d),A.Y(v.G.Number(s.e)))},
$S:0}
A.fT.prototype={
$0(){return this.a.bg(A.Y(v.G.Number(this.b)))},
$S:0}
A.fS.prototype={
$0(){return this.a.cM(this.b)},
$S:0}
A.fL.prototype={
$0(){var s,r,q=this.b.aM()
if(q>2147483647)throw A.b(A.bl(1802))
s=this.a.b
s===$&&A.M()
s=A.aE(s.buffer,0,null)
r=B.b.G(this.c,2)
s.$flags&2&&A.E(s)
s[r]=q},
$S:0}
A.fK.prototype={
$0(){var s,r=this.b.aM(),q=this.a.b
q===$&&A.M()
s=v.G.BigInt(r)
A.lJ(A.lI(q.buffer,0,null),this.c,s,!0)},
$S:0}
A.fN.prototype={
$0(){return this.a.cK(this.b)},
$S:0}
A.fU.prototype={
$0(){return this.a.cN(this.b)},
$S:0}
A.fE.prototype={
$0(){var s,r=this.b.cH(),q=this.a.b
q===$&&A.M()
q=A.aE(q.buffer,0,null)
s=B.b.G(this.c,2)
q.$flags&2&&A.E(q)
q[s]=r},
$S:0}
A.fI.prototype={
$0(){return this.a.gbS()},
$S:3}
A.fJ.prototype={
$0(){var s=this.a
if(t.b.b(s))return s.e6(this.b,this.c)
return 12},
$S:3}
A.fQ.prototype={
$0(){var s=this.a
if(t.b.b(s))return s.gbU()
return 4096},
$S:3}
A.fB.prototype={
$0(){var s=this,r=s.a.b
r===$&&A.M()
s.c.$3(s.d,A.bY(r,s.b,null),A.Y(v.G.Number(s.e)))},
$S:2}
A.fC.prototype={
$0(){var s,r,q=this,p=q.a.b
p===$&&A.M()
s=A.l0(p,q.b,q.c)
r=A.l0(p,q.d,q.e)
return q.f.giF().$2(s,r)},
$S:3}
A.fA.prototype={
$0(){return this.a.$1(this.b)},
$S:3}
A.fz.prototype={
$0(){return this.a.giH().$1(this.b)},
$S:3}
A.fy.prototype={
$0(){return this.a.giG().$2(this.b,this.c)},
$S:3}
A.cr.prototype={
I(a,b,c,d){var s,r=null,q={},p=A.Z(A.kQ(this.a,v.G.Symbol.asyncIterator,r,r,r,r)),o=this.$ti.h("cc<1>"),n=new A.cc(r,r,r,r,o)
q.a=null
s=new A.fa(q,this,p,n)
n.d=s
n.f=new A.fb(q,n,s)
return new A.c3(n,o.h("c3<1>")).I(a,b,c,d)},
b8(a,b,c){return this.I(a,null,b,c)}}
A.fa.prototype={
$0(){var s,r=this,q=r.c.next(),p=r.a
p.a=q
s=r.d
A.a_(q,t.m).am(new A.fc(p,r.b,s,r),s.gfs(),t.P)},
$S:0}
A.fc.prototype={
$1(a){var s,r,q=this,p=a.done
if(p==null)p=null
s=a.value
r=q.c
if(p===!0){r.m()
q.a.a=null}else{r.E(0,s==null?q.b.$ti.c.a(s):s)
q.a.a=null
p=r.b
if(!((p&1)!==0?(r.gP().e&4)!==0:(p&2)===0))q.d.$0()}},
$S:8}
A.fb.prototype={
$0(){var s,r
if(this.a.a==null){s=this.b
r=s.b
s=!((r&1)!==0?(s.gP().e&4)!==0:(r&2)===0)}else s=!1
if(s)this.c.$0()},
$S:0}
A.bq.prototype={
p(){var s=0,r=A.i(t.H),q=this,p
var $async$p=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:p=q.b
if(p!=null)p.p()
p=q.c
if(p!=null)p.p()
q.c=q.b=null
return A.f(null,r)}})
return A.h($async$p,r)},
gl(){var s=this.a
return s==null?A.y(A.x("Await moveNext() first")):s},
j(){var s,r,q,p=this,o=p.a
if(o!=null)o.continue()
o=new A.k($.l,t.k)
s=new A.D(o,t.fa)
r=p.d
q=t.m
p.b=A.a2(r,"success",new A.j_(p,s),!1,q)
p.c=A.a2(r,"error",new A.j0(p,s),!1,q)
return o}}
A.j_.prototype={
$1(a){var s,r=this.a
r.p()
s=r.$ti.h("1?").a(r.d.result)
r.a=s
this.b.B(s!=null)},
$S:1}
A.j0.prototype={
$1(a){var s=this.a
s.p()
s=s.d.error
if(s==null)s=a
this.b.H(s)},
$S:1}
A.fp.prototype={
$1(a){this.a.B(this.c.a(this.b.result))},
$S:1}
A.fq.prototype={
$1(a){var s=this.b.error
if(s==null)s=a
this.a.H(s)},
$S:1}
A.fu.prototype={
$1(a){this.a.B(this.c.a(this.b.result))},
$S:1}
A.fv.prototype={
$1(a){var s=this.b.error
if(s==null)s=a
this.a.H(s)},
$S:1}
A.fw.prototype={
$1(a){this.a.H(new A.as("IndexedDB open blocked"))},
$S:1}
A.hg.prototype={
$1(a){return A.Z(a[1])},
$S:48}
A.io.prototype={
fC(){var s={}
s.dart=new A.ip(this).$0()
return s},
bG(a){return this.hz(a)},
hz(a){var s=0,r=A.i(t.m),q,p=this,o,n
var $async$bG=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:s=3
return A.c(A.a_(v.G.WebAssembly.instantiateStreaming(a,p.fC()),t.m),$async$bG)
case 3:o=c
n=o.instance.exports
if("_initialize" in n)t.g.a(n._initialize).call()
q=o.instance
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$bG,r)}}
A.ip.prototype={
$0(){var s=this.a.a,r=A.Z(v.G.Object),q=A.Z(r.create.apply(r,[null]))
q.error_log=A.ax(s.ghE())
q.localtime=A.a7(s.ghC())
q.xOpen=A.l6(s.gij())
q.xDelete=A.ki(s.gi4())
q.xAccess=A.cg(s.ghX())
q.xFullPathname=A.cg(s.gie())
q.xRandomness=A.ki(s.gil())
q.xSleep=A.a7(s.gir())
q.xCurrentTimeInt64=A.a7(s.gi2())
q.xClose=A.ax(s.gi0())
q.xRead=A.cg(s.gio())
q.xWrite=A.cg(s.giz())
q.xTruncate=A.a7(s.giv())
q.xSync=A.a7(s.git())
q.xFileSize=A.a7(s.gi9())
q.xFileSize64=A.a7(s.gib())
q.xLock=A.a7(s.gih())
q.xUnlock=A.a7(s.gix())
q.xCheckReservedLock=A.a7(s.ghZ())
q.xDeviceCharacteristics=A.ax(s.gbS())
q.xFileControl=A.ki(s.gi7())
q.xSectorSize=A.ax(s.gbU())
q["dispatch_()v"]=A.ax(s.gfR())
q["dispatch_()i"]=A.ax(s.gfM())
q.dispatch_update=A.l6(s.gfP())
q.dispatch_xFunc=A.cg(s.gfX())
q.dispatch_xStep=A.cg(s.gh0())
q.dispatch_xInverse=A.cg(s.gfZ())
q.dispatch_xValue=A.a7(s.gh2())
q.dispatch_xFinal=A.a7(s.gfV())
q.dispatch_compare=A.l6(s.gfT())
q.dispatch_busy=A.a7(s.gfK())
q.changeset_apply_filter=A.a7(s.gfI())
q.changeset_apply_conflict=A.ki(s.gfG())
return q},
$S:16}
A.bW.prototype={}
A.fh.prototype={
bK(){var s=0,r=A.i(t.H),q=this,p,o
var $async$bK=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:p=new A.k($.l,t._)
o=v.G.indexedDB.open(q.b,1)
o.onupgradeneeded=A.ax(new A.fk(o))
new A.D(p,t.G).B(A.nr(o,t.m))
s=2
return A.c(p,$async$bK)
case 2:q.a=b
return A.f(null,r)}})
return A.h($async$bK,r)},
aD(a,b){return this.fg(a,b)},
fg(a,b){var s=0,r=A.i(t.H),q=this,p,o,n
var $async$aD=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:n=q.a
n.toString
p=n.transaction($.n6(),b)
o=A.oq(p)
s=2
return A.c(A.qr(new A.fj(a,o,p),t.aQ),$async$aD)
case 2:s=3
return A.c(o.b.a,$async$aD)
case 3:if(o.c){n=q.a
if(n!=null)n.close()
q.a=null}return A.f(null,r)}})
return A.h($async$aD,r)},
f7(a){return this.aD(new A.fi(a),"readwrite")}}
A.fk.prototype={
$1(a){var s=A.Z(this.a.result)
if(J.N(a.oldVersion,0)){s.createObjectStore("files",{autoIncrement:!0}).createIndex("fileName","name",{unique:!0})
s.createObjectStore("blocks")}},
$S:8}
A.fj.prototype={
$0(){var s=0,r=A.i(t.P),q=1,p=[],o=this,n,m
var $async$$0=A.j(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:q=3
s=6
return A.c(o.a.$1(o.b),$async$$0)
case 6:q=1
s=5
break
case 3:q=2
m=p.pop()
o.c.abort()
throw m
s=5
break
case 2:s=1
break
case 5:o.c.commit()
return A.f(null,r)
case 1:return A.e(p.at(-1),r)}})
return A.h($async$$0,r)},
$S:50}
A.fi.prototype={
$1(a){return this.e7(a)},
e7(a){var s=0,r=A.i(t.H),q=this,p,o,n
var $async$$1=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:p=q.a,o=p.length,n=0
case 2:if(!(n<p.length)){s=4
break}s=5
return A.c(p[n].F(a),$async$$1)
case 5:case 3:p.length===o||(0,A.T)(p),++n
s=2
break
case 4:return A.f(null,r)}})
return A.h($async$$1,r)},
$S:12}
A.dg.prototype={
ev(a){var s=A.kh(new A.jt(this)),r=this.a
r.oncomplete=s
r.onabort=s
r.onerror=A.kh(new A.ju(this))},
cd(a,b,c){var s=t.t
return v.G.IDBKeyRange.bound(A.v([a,c],s),A.v([a,b],s))},
f9(a){return this.cd(a,9007199254740992,0)},
fa(a,b){return this.cd(a,9007199254740992,b)},
bF(){var s=0,r=A.i(t.g6),q,p=this,o,n,m,l,k
var $async$bF=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:l=A.aC(t.N,t.S)
k=new A.bq(p.d.index("fileName").openKeyCursor(),t.O)
case 3:s=5
return A.c(k.j(),$async$bF)
case 5:if(!b){s=4
break}o=k.a
if(o==null)o=A.y(A.x("Await moveNext() first"))
n=o.key
n.toString
A.dE(n)
m=o.primaryKey
m.toString
l.q(0,n,A.Y(A.by(m)))
s=3
break
case 4:q=l
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$bF,r)},
bu(a){return this.h9(a)},
h9(a){var s=0,r=A.i(t.I),q,p=this,o
var $async$bu=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:o=A
s=3
return A.c(A.ar(p.d.index("fileName").getKey(a),t.i),$async$bu)
case 3:q=o.Y(c)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$bu,r)},
ce(a){return A.ar(this.d.get(a),t.A).bf(new A.js(a),t.m)},
aP(a,b){return this.el(a,b)},
el(a,b){var s=0,r=A.i(t.fQ),q,p=this,o,n,m,l,k,j,i,h,g,f,e
var $async$aP=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:s=3
return A.c(p.ce(a),$async$aP)
case 3:h=d
g=h.length
f=new A.at(new Uint8Array(g),g)
e=new A.bq(p.e.openCursor(p.f9(a)),t.O)
g=t.a,o=v.G,n=t.c,m=t.H
case 4:s=6
return A.c(e.j(),$async$aP)
case 6:if(!d){s=5
break}l=e.a
if(l==null)l=A.y(A.x("Await moveNext() first"))
k=n.a(l.key)
j=A.Y(A.by(k[1]))
if(j>=h.length){s=5
break}i=new A.jv(f,j,Math.min(4096,h.length-j))
if(l.value instanceof o.Blob)b.push(A.hP(A.Z(l.value)).bf(i,m))
else i.$1(g.a(l.value))
s=4
break
case 5:q=f
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$aP,r)},
bq(a){return this.fB(a)},
fB(a){var s=0,r=A.i(t.S),q,p=this,o
var $async$bq=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:if((p.b.a.a&30)!==0)A.y(A.x("IDB transaction already completed"))
o=A
s=3
return A.c(A.ar(p.d.put({name:a,length:0}),t.i),$async$bq)
case 3:q=o.Y(c)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$bq,r)},
ao(a,b){return this.hW(a,b)},
hW(a,b){var s=0,r=A.i(t.H),q=this,p,o,n,m,l
var $async$ao=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:if((q.b.a.a&30)!==0)A.y(A.x("IDB transaction already completed"))
s=2
return A.c(q.ce(a),$async$ao)
case 2:p=d
o=b.b
n=A.A(o).h("aB<1>")
m=A.cK(new A.aB(o,n),n.h("q.E"))
B.c.eg(m)
s=3
return A.c(A.lC(new A.aD(m,new A.jw(new A.jx(q,a),b),A.aw(m).h("aD<1,w<~>>")),t.H),$async$ao)
case 3:s=b.c!==p.length?4:5
break
case 4:l=new A.bq(q.d.openCursor(a),t.O)
s=6
return A.c(l.j(),$async$ao)
case 6:s=7
return A.c(A.ar(l.gl().update({name:p.name,length:b.c}),t.X),$async$ao)
case 7:case 5:return A.f(null,r)}})
return A.h($async$ao,r)},
an(a,b,c){return this.hT(0,b,c)},
hT(a,b,c){var s=0,r=A.i(t.H),q=this,p,o
var $async$an=A.j(function(d,e){if(d===1)return A.e(e,r)
for(;;)switch(s){case 0:if((q.b.a.a&30)!==0)A.y(A.x("IDB transaction already completed"))
s=2
return A.c(q.ce(b),$async$an)
case 2:p=e
s=p.length>c?3:4
break
case 3:s=5
return A.c(A.ar(q.e.delete(q.fa(b,B.b.U(c,4096)*4096)),t.X),$async$an)
case 5:case 4:o=new A.bq(q.d.openCursor(b),t.O)
s=6
return A.c(o.j(),$async$an)
case 6:s=7
return A.c(A.ar(o.gl().update({name:p.name,length:c}),t.X),$async$an)
case 7:return A.f(null,r)}})
return A.h($async$an,r)},
bs(a){return this.fF(a)},
fF(a){var s=0,r=A.i(t.H),q=this,p
var $async$bs=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:if((q.b.a.a&30)!==0)A.y(A.x("IDB transaction already completed"))
p=t.X
s=2
return A.c(A.lC(A.v([A.ar(q.e.delete(q.cd(a,9007199254740992,0)),p),A.ar(q.d.delete(a),p)],t.M),t.H),$async$bs)
case 2:return A.f(null,r)}})
return A.h($async$bs,r)}}
A.jt.prototype={
$0(){this.a.b.L()},
$S:2}
A.ju.prototype={
$0(){var s=this.a,r=s.a.error
if(r==null)r=new v.G.DOMException("IDB transaction error")
s.b.H(r)},
$S:2}
A.js.prototype={
$1(a){if(a==null)throw A.b(A.b4(this.a,"fileId","File not found in database"))
else return a},
$S:52}
A.jv.prototype={
$1(a){var s=this.a
s.aO(s,this.b,J.co(a,0,this.c))},
$S:53}
A.jx.prototype={
ed(a,b){var s=0,r=A.i(t.H),q=this,p,o,n,m,l,k
var $async$$2=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:p=q.a.e
o=q.b
n=t.t
s=2
return A.c(A.ar(p.openCursor(v.G.IDBKeyRange.only(A.v([o,a],n))),t.A),$async$$2)
case 2:m=d
l=t.a.a(B.d.ga5(b))
k=t.X
s=m==null?3:5
break
case 3:s=6
return A.c(A.ar(p.put(l,A.v([o,a],n)),k),$async$$2)
case 6:s=4
break
case 5:s=7
return A.c(A.ar(m.update(l),k),$async$$2)
case 7:case 4:return A.f(null,r)}})
return A.h($async$$2,r)},
$2(a,b){return this.ed(a,b)},
$S:54}
A.jw.prototype={
$1(a){var s=this.b.b.n(0,a)
s.toString
return this.a.$2(a,s)},
$S:55}
A.ja.prototype={
fo(a,b,c){B.d.aO(this.b.e1(a,new A.jb(this,a)),b,c)},
fz(a,b){var s,r,q,p,o,n,m,l
for(s=b.length,r=0;r<s;r=l){q=a+r
p=B.b.U(q,4096)
o=B.b.bV(q,4096)
n=s-r
if(o!==0)m=Math.min(4096-o,n)
else{m=Math.min(4096,n)
o=0}l=r+m
this.fo(p*4096,o,J.co(B.d.ga5(b),b.byteOffset+r,m))}this.c=Math.max(this.c,a+s)}}
A.jb.prototype={
$0(){var s=new Uint8Array(4096),r=this.a.a,q=r.length,p=this.b
if(q>p)B.d.aO(s,0,J.co(B.d.ga5(r),r.byteOffset+p,Math.min(4096,q-p)))
return s},
$S:56}
A.eS.prototype={}
A.aP.prototype={
b0(a){var s=this
if(s.e||s.d.a==null)A.y(A.bl(10))
if(a.cs(s.x)){s.ad(!0)
return a.d.a}else return A.hn(null,t.H)},
ad(a){return this.fm(a)},
fm(a){var s=0,r=A.i(t.H),q,p=this,o,n
var $async$ad=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:if(a&&!p.r){s=1
break}s=p.f==null&&!p.x.gaJ(0)?3:4
break
case 3:o=p.x
n=A.cK(o,o.$ti.h("q.E"))
o.V(0)
o=p.d.f7(n).J(new A.hs(p,n,a))
p.f=o
s=5
return A.c(o,$async$ad)
case 5:case 4:case 1:return A.f(q,r)}})
return A.h($async$ad,r)},
m(){var s=0,r=A.i(t.H),q,p=this,o,n
var $async$m=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:if(!p.e){o=p.b0(new A.de(new A.ht(),new A.D(new A.k($.l,t.D),t.F)))
p.e=!0
p.ad(!1)
q=o
s=1
break}else{n=p.x
if(!n.gaJ(0)){q=n.gcw(0).d.a
s=1
break}}case 1:return A.f(q,r)}})
return A.h($async$m,r)},
az(a,b){return this.eK(a,b)},
eK(a,b){var s=0,r=A.i(t.S),q,p=this,o,n
var $async$az=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:n=p.z
s=n.Z(b)?3:5
break
case 3:n=n.n(0,b)
n.toString
q=n
s=1
break
s=4
break
case 5:s=6
return A.c(a.bu(b),$async$az)
case 6:o=d
o.toString
n.q(0,b,o)
q=o
s=1
break
case 4:case 1:return A.f(q,r)}})
return A.h($async$az,r)},
aX(){var s=0,r=A.i(t.H),q=this,p
var $async$aX=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:p=A.v([],t.M)
s=2
return A.c(q.d.aD(new A.hr(q,p),"readonly"),$async$aX)
case 2:s=3
return A.c(A.nE(p,t.H),$async$aX)
case 3:return A.f(null,r)}})
return A.h($async$aX,r)},
dU(){var s=this.f
return s==null?this.ad(!1):s},
bQ(a,b){return this.w.d.Z(a)?1:0},
cI(a,b){var s=this
s.w.d.u(0,a)
if(!s.y.u(0,a))s.b0(new A.da(s,a,new A.D(new A.k($.l,t.D),t.F)))},
cJ(a){return new v.G.URL(a,"file:///").pathname},
ap(a,b){var s,r,q,p=this,o=a.a
if(o==null)o=A.lD(p.b,"/")
s=p.w
r=s.d.Z(o)?1:0
q=s.ap(new A.cW(o),b)
if(r===0)if((b&8)!==0)p.y.E(0,o)
else p.b0(new A.c5(p,o,new A.D(new A.k($.l,t.D),t.F)))
return new A.ca(new A.eN(p,q.a,o),0)},
cL(a){}}
A.hs.prototype={
$0(){var s,r,q,p,o=this.a
o.f=null
for(s=this.b,r=s.length,q=0;q<s.length;s.length===r||(0,A.T)(s),++q){p=s[q].d.a
if((p.a&30)!==0)A.y(A.x("Future already completed"))
p.aw(null)}o.ad(this.c)},
$S:2}
A.ht.prototype={
$1(a){return this.e9(a)},
e9(a){var s=0,r=A.i(t.H)
var $async$$1=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:a.c=!0
return A.f(null,r)}})
return A.h($async$$1,r)},
$S:12}
A.hr.prototype={
$1(a){return this.e8(a)},
e8(a){var s=0,r=A.i(t.H),q=this,p,o,n,m,l,k,j
var $async$$1=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:s=2
return A.c(a.bF(),$async$$1)
case 2:m=c
l=q.a
l.z.a4(0,m)
p=m.gbt(),p=p.gt(p),o=q.b,l=l.w.d
case 3:if(!p.j()){s=4
break}n=p.gl()
k=l
j=n.a
s=5
return A.c(a.aP(n.b,o),$async$$1)
case 5:k.q(0,j,c)
s=3
break
case 4:return A.f(null,r)}})
return A.h($async$$1,r)},
$S:12}
A.eN.prototype={
bT(a,b){this.b.bT(a,b)},
gbS(){return 0},
gbU(){return 4096},
cH(){return this.b.d>=2?1:0},
bR(){},
aM(){return this.b.aM()},
cK(a){this.b.d=a
return null},
cM(a){},
e6(a,b){return 12},
bg(a){var s=this,r=s.a
if(r.e||r.d.a==null)A.y(A.bl(10))
s.b.bg(a)
if(!r.y.dK(0,s.c))r.b0(new A.de(new A.jr(s,a),new A.D(new A.k($.l,t.D),t.F)))},
cN(a){this.b.d=a
return null},
aN(a,b){var s,r,q,p,o,n,m=this,l=m.a
if(l.e||l.d.a==null)A.y(A.bl(10))
s=m.c
if(l.y.dK(0,s)){m.b.aN(a,b)
return}r=l.w.d.n(0,s)
if(r==null)r=new A.at(new Uint8Array(0),0)
q=J.co(B.d.ga5(r.a),0,r.b)
m.b.aN(a,b)
p=new Uint8Array(a.length)
B.d.aO(p,0,a)
o=A.v([],t.f6)
n=$.l
o.push(new A.eS(b,p))
l.b0(new A.ce(l,s,q,o,new A.D(new A.k(n,t.D),t.F)))},
$ia1:1,
$id2:1}
A.jr.prototype={
$1(a){return this.ec(a)},
ec(a){var s=0,r=A.i(t.H),q,p=this,o,n
var $async$$1=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:o=p.a
n=a
s=3
return A.c(o.a.az(a,o.c),$async$$1)
case 3:q=n.an(0,c,p.b)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$$1,r)},
$S:12}
A.V.prototype={
cs(a){a.bm(a.c,this,!1)
return!0}}
A.de.prototype={
F(a){return this.w.$1(a)}}
A.da.prototype={
cs(a){var s,r,q,p
if(!a.gaJ(0)){s=a.gcw(0)
for(r=this.x;s!=null;)if(s instanceof A.da)if(s.x===r)return!1
else s=s.gba()
else if(s instanceof A.ce){q=s.gba()
if(s.x===r){p=s.a
p.toString
p.cj(A.A(s).h("X.E").a(s))}s=q}else if(s instanceof A.c5){if(s.x===r){r=s.a
r.toString
r.cj(A.A(s).h("X.E").a(s))
return!1}s=s.gba()}else break}a.bm(a.c,this,!1)
return!0},
F(a){return this.hQ(a)},
hQ(a){var s=0,r=A.i(t.H),q=this,p,o,n
var $async$F=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:p=q.w
o=q.x
s=2
return A.c(p.az(a,o),$async$F)
case 2:n=c
p.z.u(0,o)
s=3
return A.c(a.bs(n),$async$F)
case 3:return A.f(null,r)}})
return A.h($async$F,r)}}
A.c5.prototype={
F(a){return this.hP(a)},
hP(a){var s=0,r=A.i(t.H),q=this,p,o,n
var $async$F=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:p=q.x
o=q.w.z
n=p
s=2
return A.c(a.bq(p),$async$F)
case 2:o.q(0,n,c)
return A.f(null,r)}})
return A.h($async$F,r)}}
A.ce.prototype={
cs(a){var s,r=a.b===0?null:a.gcw(0)
for(s=this.x;r!=null;)if(r instanceof A.ce)if(r.x===s){B.c.a4(r.z,this.z)
return!1}else r=r.gba()
else if(r instanceof A.c5){if(r.x===s)break
r=r.gba()}else break
a.bm(a.c,this,!1)
return!0},
F(a){return this.hR(a)},
hR(a){var s=0,r=A.i(t.H),q=this,p,o,n,m,l,k
var $async$F=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:m=q.y
l=new A.ja(m,A.aC(t.S,t.p),m.length)
for(m=q.z,p=m.length,o=0;o<m.length;m.length===p||(0,A.T)(m),++o){n=m[o]
l.fz(n.a,n.b)}k=a
s=3
return A.c(q.w.az(a,q.x),$async$F)
case 3:s=2
return A.c(k.ao(c,l),$async$F)
case 2:return A.f(null,r)}})
return A.h($async$F,r)}}
A.bI.prototype={
Y(){return"FileType."+this.b}}
A.bS.prototype={
T(){var s=this.d
if(s!=null)return s
throw A.b(A.x("VFS closed"))},
bQ(a,b){var s=$.kJ().n(0,a)
if(s==null)return this.e.d.Z(a)?1:0
else return this.T().dR(s)?1:0},
cI(a,b){var s=$.kJ().n(0,a)
if(s==null){this.e.d.u(0,a)
return null}else this.T().b9(s,!1)},
cJ(a){return new v.G.URL(a,"file:///").pathname},
ap(a,b){var s,r,q=this,p=a.a
if(p==null)return q.e.ap(a,b)
s=$.kJ().n(0,p)
if(s==null)return q.e.ap(a,b)
r=q.T()
if(!r.dR(s))if((b&4)!==0){r.ah(s).truncate(0)
r.b9(s,!0)}else throw A.b(B.aw)
return new A.ca(new A.eX(q,s,(b&8)!==0),0)},
cL(a){},
m(){var s=this.d
if(s!=null){s.b.close()
s.c.close()
s.d.close()}this.d=null},
a7(a,b){return this.hK(a,b)},
hI(a){return this.a7(a,!1)},
hK(a,b){var s=0,r=A.i(t.H),q=this,p,o,n,m,l,k
var $async$a7=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:m=new A.hU(a,b)
s=2
return A.c(m.$1("meta"),$async$a7)
case 2:l=d
k=J.N(l.getSize(),0)
l.truncate(2)
s=3
return A.c(m.$1("database"),$async$a7)
case 3:p=d
s=4
return A.c(m.$1("journal"),$async$a7)
case 4:o=d
n=q.d=new A.jD(new Uint8Array(2),l,p,o)
if(k){n.b9(B.A,p.getSize()>0)
n.b9(B.B,o.getSize()>0)}return A.f(null,r)}})
return A.h($async$a7,r)}}
A.hU.prototype={
eb(a){var s=0,r=A.i(t.m),q,p=this,o,n
var $async$$1=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:o=t.m
s=3
return A.c(A.a_(p.a.getFileHandle(a,{create:!0}),o),$async$$1)
case 3:n=c
s=4
return A.c(A.a_(p.b?n.createSyncAccessHandle({mode:"readwrite-unsafe"}):n.createSyncAccessHandle(),o),$async$$1)
case 4:q=c
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$$1,r)},
$1(a){return this.eb(a)},
$S:57}
A.eX.prototype={
e2(a,b){return A.lA(this.a.T().ah(this.b),a,{at:b})},
cH(){return this.d>=2?1:0},
bR(){var s=this.a,r=this.b
s.T().ah(r).flush()
if(this.c)s.T().b9(r,!1)},
aM(){return this.a.T().ah(this.b).getSize()},
cK(a){this.d=a},
cM(a){this.a.T().ah(this.b).flush()},
bg(a){this.a.T().ah(this.b).truncate(a)},
cN(a){this.d=a},
aN(a,b){if(A.lB(this.a.T().ah(this.b),a,{at:b})<a.length)throw A.b(B.ay)}}
A.jD.prototype={
dR(a){var s=this.a
A.lA(this.b,s,{at:0})
return s[a.a]!==0},
b9(a,b){var s=this.a,r=b?1:0
s.$flags&2&&A.E(s)
s[a.a]=r
A.lB(this.b,s,{at:0})},
ah(a){var s
switch(a.a){case 0:s=this.c
break
case 1:s=this.d
break
default:s=null}return s}}
A.ih.prototype={
es(a,b){var s=this,r=s.c
r.a!==$&&A.mK()
r.a=s
A.jc(new A.ii(s),t.fM)
r=t.S
A.jc(new A.ij(s),r)
s.r=A.jc(new A.ik(s),r)
s.w=A.jc(new A.il(s),r)},
b1(a,b){var s=a.length,r=this.bH(s+b),q=A.ag(this.b.buffer,0,null)
s=r+s
B.d.R(q,r,s,a)
B.d.dS(q,s,s+b,0)
return r},
cn(a){return this.b1(a,0)},
bH(a){var s=this.d.dart_sqlite3_malloc(a)
if(s===0)throw A.b(A.x("out of wasm memory"))
return s},
dN(a,b){var s=b==null?null:b
return this.d.dart_sqlite3_updates(a,s)},
dL(a,b){var s=b==null?null:b
return this.d.dart_sqlite3_commits(a,s)},
dM(a,b){var s=b==null?null:b
return this.d.dart_sqlite3_rollbacks(a,s)}}
A.ii.prototype={
$1(a){a.iI(this.a)},
$S:58}
A.ij.prototype={
$1(a){return this.a.d.sqlite3session_delete(a)},
$S:4}
A.ik.prototype={
$1(a){return this.a.d.sqlite3_close_v2(a)},
$S:4}
A.il.prototype={
$1(a){return this.a.d.sqlite3_finalize(a)},
$S:4}
A.cu.prototype={}
A.hJ.prototype={
er(a){var s,r=this,q=r.a
q.start()
r.c=A.a2(q,"message",new A.hN(r),!1,t.m)
s=a.b
if(a.c==null&&s!=null){q=$.dL()
q.toString
A.d3(q,s,null,null,!1).bf(new A.hO(r),t.P)}},
c5(a){return this.eV(a)},
eV(a){var s=0,r=A.i(t.H),q=this
var $async$c5=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:A.qa(a,new A.hK(q),q.ghn(),new A.hL(q),new A.hM(q))
return A.f(null,r)}})
return A.h($async$c5,r)},
bi(a,b,c){return this.ef(a,b,c,c)},
ef(a,b,c,d){var s=0,r=A.i(d),q,p=this,o,n,m
var $async$bi=A.j(function(e,f){if(e===1)return A.e(f,r)
for(;;)switch(s){case 0:if((p.b.a.a&30)!==0)throw A.b(A.ni(null))
o=p.e++
n=new A.k($.l,t._)
p.f.q(0,o,new A.D(n,t.G))
a.i=o
p.a.postMessage(a,A.ck(a))
s=3
return A.c(n,$async$bi)
case 3:m=f
if(J.N(m.t,b.b)){q=c.a(m)
s=1
break}else throw A.b(A.o4(m))
case 1:return A.f(q,r)}})
return A.h($async$bi,r)},
f_(a){var s,r,q=this,p=q.b
if((p.a.a&30)!==0)return
q.a.postMessage("_disconnect")
s=q.c
if(s!=null)s.p()
s=q.d
if(s!=null)s.p()
for(s=q.f,r=new A.bK(s,s.r,s.e);r.j();)r.d.H(new A.dU(a))
s.V(0)
p.L()},
dh(){return this.f_(null)}}
A.hN.prototype={
$1(a){if(a.data=="_disconnect"){this.a.dh()
return}this.a.c5(A.Z(a.data))},
$S:1}
A.hO.prototype={
$1(a){this.a.dh()
a.a.L()},
$S:59}
A.hM.prototype={
$1(a){var s=this.a.f.u(0,a.i)
if(s!=null)s.B(a)},
$S:8}
A.hL.prototype={
$1(a){return this.ea(a)},
ea(a1){var s=0,r=A.i(t.P),q=1,p=[],o=[],n=this,m,l,k,j,i,h,g,f,e,d,c,b,a,a0
var $async$$1=A.j(function(a2,a3){if(a2===1){p.push(a3)
s=q}for(;;)switch(s){case 0:f=null
e=a1.i
d=n.a
c=d.r
b=v.G
a=new b.AbortController()
c.q(0,e,a)
m=a
q=3
j=d.fO(a1,m.signal)
s=6
return A.c(t.em.b(j)?j:A.c8(j,t.m),$async$$1)
case 6:f=a3
o.push(5)
s=4
break
case 3:q=2
a0=p.pop()
l=A.R(a0)
k=A.Q(a0)
if(!(l instanceof A.b3)){b.console.error("Error in worker: "+J.aL(l))
b.console.error("Original trace: "+A.u(k))}b=l
if(b instanceof A.bT){h=A.nv(b)
g=0}else{g=b instanceof A.b3?1:null
h=null}f={e:J.aL(b),s:g,r:h,i:e,t:"errorResponse"}
o.push(5)
s=4
break
case 2:o=[1]
case 4:q=1
c.u(0,e)
s=o.pop()
break
case 5:c=f
d.a.postMessage(c,A.ck(c))
return A.f(null,r)
case 1:return A.e(p.at(-1),r)}})
return A.h($async$$1,r)},
$S:60}
A.hK.prototype={
$1(a){var s=this.a.r.u(0,a.i)
if(s!=null)s.abort()},
$S:8}
A.dU.prototype={
i(a){return"Channel to database worker is closed: "+A.u(this.a)}}
A.fW.prototype={
a0(a){return this.hA(a)},
hA(a){var s=0,r=A.i(t.n),q
var $async$a0=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:q=A.ir(a,null)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$a0,r)}}
A.dY.prototype={}
A.fx.prototype={}
A.bo.prototype={}
A.e5.prototype={
bI(){var s=0,r=A.i(t.H),q=this
var $async$bI=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:s=!q.c?2:3
break
case 2:s=4
return A.c(q.a.hI(q.b),$async$bI)
case 4:case 3:return A.f(null,r)}})
return A.h($async$bI,r)},
cC(){var s=0,r=A.i(t.H),q=this
var $async$cC=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:if(!q.c)q.a.m()
return A.f(null,r)}})
return A.h($async$cC,r)}}
A.hq.prototype={
hS(a){var s=this.a,r=this.d
if(this.c)return s.transfer(r)
else return s.slice(0,r)},
eM(a){var s,r,q,p=this,o=p.b
for(s=o;s<a;){s*=2
p.b=s}if(p.c)p.a=p.a.transfer(s)
else{r=v.G
q=new r.ArrayBuffer(s)
new r.Uint8Array(q,0,p.b).set(new r.Uint8Array(p.a,0,o))
p.a=q}}}
A.iv.prototype={
$1(a){var s=new A.k($.l,t.D),r=new A.aA(new A.D(s,t.F))
this.a.a=r
this.b.B(r)
return A.nF(s)},
$S:61}
A.iw.prototype={
$2(a,b){var s,r,q
A.Z(a)
s=J.N(a.name,"AbortError")
r=this.a.a
if(r!=null){if((r.a.a.a&30)===0){q=this.b
if(q!=null)q.$0()}}else{q=this.c
if(s)q.af(new A.b3("Operation was cancelled"),b)
else q.af(a,b)}return null},
$S:62}
A.aA.prototype={}
A.e_.prototype={
gfA(){if(this.c.a)return!1
return!this.d||this.f!=null},
ar(a){return this.ez(a)},
ez(a){var s=0,r=A.i(t.H),q=1,p=[],o=this,n,m,l,k,j,i
var $async$ar=A.j(function(b,c){if(b===1){p.push(c)
s=q}for(;;)switch(s){case 0:j=$.dL()
j.toString
n=j
m=null
l=null
q=3
s=6
return A.c(A.d3(n,o.a,null,o.geW(),!0),$async$ar)
case 6:m=c
s=7
return A.c(A.d3(n,o.b,a,null,!1),$async$ar)
case 7:l=c
j=o.e
j=j==null?null:j.bI()
s=8
return A.c(j instanceof A.k?j:A.c8(j,t.H),$async$ar)
case 8:o.f=new A.W(m,l)
q=1
s=5
break
case 3:q=2
i=p.pop()
j=m
if(j!=null)j.a.L()
j=l
if(j!=null)j.a.L()
throw i
s=5
break
case 2:s=1
break
case 5:return A.f(null,r)
case 1:return A.e(p.at(-1),r)}})
return A.h($async$ar,r)},
eX(){this.e3()},
cz(a,b,c){return this.c.bP(new A.h8(this,a,b,c),b,c)},
e3(){return this.c.cG(new A.h9(this),t.H)}}
A.h8.prototype={
$0(){var s,r=this,q=r.a
if(!q.d||q.f!=null)return r.b.$0()
s=r.d
return q.ar(r.c).bf(new A.h7(r.b,s),s)},
$S(){return this.d.h("0/()")}}
A.h7.prototype={
$1(a){return this.a.$0()},
$S(){return this.b.h("0/(~)")}}
A.h9.prototype={
$0(){var s,r,q,p=this.a,o=p.f
if(o!=null){s=o.a
r=o.b
q=p.e
if(q!=null)q.cC()
s.a.L()
r.a.L()
p.f=null}},
$S:2}
A.cM.prototype={
bP(a,b,c){return this.hV(a,b,c,c)},
cG(a,b){return this.bP(a,null,b)},
hV(a,b,c,d){var s=0,r=A.i(d),q,p=this,o,n,m,l,k,j,i,h,g
var $async$bP=A.j(function(e,f){if(e===1)return A.e(f,r)
for(;;)switch(s){case 0:h={}
g=b==null
if(J.N(g?null:b.aborted,!0))throw A.b(B.j)
h.a=!1
o=new A.hE(h,p)
if(!p.a){h.a=p.a=!0
q=A.e7(a,c).J(o)
s=1
break}else{n={}
m=new A.k($.l,c.h("k<0>"))
l=new A.D(m,c.h("D<0>"))
n.a=null
h=new A.hD(h,n,l,a,c)
if(!g)n.a=A.a2(b,"abort",new A.hC(n,p,l,h),!1,t.m)
g=p.b
n=g.a
k=g.c
n[k]=h
n=n.length
k=(k+1&n-1)>>>0
g.c=k
if(g.b===k){j=A.hz(n*2,null,!1,g.$ti.h("1?"))
h=g.a
n=g.b
i=h.length-n
B.c.D(j,0,i,h,n)
B.c.D(j,i,i+g.b,g.a,0)
g.b=0
g.c=g.a.length
g.a=j}++g.d
q=m.J(o)
s=1
break}case 1:return A.f(q,r)}})
return A.h($async$bP,r)}}
A.hE.prototype={
$0(){var s,r,q,p
if(!this.a.a)return
s=this.b
r=s.b
if(!r.gaJ(0)){s=r.b
if(s===r.c)A.y(A.ec());++r.d
q=r.a
p=q[s]
if(p==null)p=r.$ti.c.a(p)
q[s]=null
r.b=(s+1&q.length-1)>>>0
p.$0()}else s.a=!1},
$S:0}
A.hD.prototype={
$0(){var s,r=this
r.a.a=!0
s=r.b.a
if(s!=null)s.p()
r.c.B(A.e7(r.d,r.e))},
$S:0}
A.hC.prototype={
$1(a){var s,r=this
r.a.a.p()
s=r.c
if((s.a.a&30)===0){r.b.b.u(0,r.d)
s.H(B.j)}},
$S:1}
A.b9.prototype={
ge5(){var s,r,q,p,o,n=this,m=t.s,l=A.v([],m)
for(s=n.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.T)(s),++q){p=s[q]
B.c.a4(l,A.v([p.a.b,p.b],m))}o={}
o.a=l
o.b=n.b
o.c=n.c
o.d=n.e
o.e=!1
o.f=!1
o.g=n.d
return o}}
A.he.prototype={
$1(a){if(a!=null)return A.dE(a)
return null},
$S:63}
A.ek.prototype={
Y(){return"MessageType."+this.b}}
A.hQ.prototype={
fO(a,b){var s,r,q,p=this,o=null
switch(a.t){case"open":return p.bz(a,b)
case"connect":return p.cr(a,b)
case"custom":return p.aF(a,b)
case"fileSystemExists":return p.b5(a,b)
case"fileSystemFlush":return p.b6(a,b)
case"fileSystemAccess":return p.b4(a,b)
case"runQuery":return p.bC(a,b)
case"exclusiveLock":return p.by(a,b)
case"releaseLock":s=p.O(a)
r=a.z
q=s.f
if((q==null?o:q.a)!==r)A.y(A.x("Lock to be released is not active."))
q.b.L()
s.f=null
return{r:null,i:a.i,t:"simpleSuccessResponse"}
case"closeDatabase":return p.bw(a,b)
case"openAdditionalConnection":return p.bA(a,b)
case"updateRequest":return p.bD(a,b)
case"rollbackRequest":return p.bB(a,b)
case"commitRequest":return p.bx(a,b)
case"dedicatedCompatibilityCheck":return p.aA(a,b)
case"sharedCompatibilityCheck":return p.aA(a,b)
case"dedicatedInSharedCompatibilityCheck":return p.aA(a,b)
default:r=A.l8(new A.al(!1,o,o,"Unsupported request "+A.u(a.t)),o)
q=new A.k($.l,t.gp)
q.a3(r)
return q}}}
A.aO.prototype={
Y(){return"FileSystemImplementation."+this.b}}
A.ao.prototype={
Y(){return"TypeCode."+this.b},
fD(a){var s=null
switch(this.a){case 0:s=A.y(A.a0("Unsupported type code",null))
break
case 1:a=A.Y(A.by(a))
s=a
break
case 2:s=A.nQ(t.V.a(a))
break
case 3:A.by(a)
s=a
break
case 4:A.dE(a)
s=a
break
case 5:t.Z.a(a)
s=a
break
case 7:A.bx(a)
s=a
break
case 6:break}return s}}
A.aN.prototype={
dI(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c="binding parameter"
a.bl()
s=a.a
r=s.c
s=s.b
q=r.d
p=q.sqlite3_bind_parameter_count(s)
o=this.a
n=o.length
if(n!==p)throw A.b(A.a0("Expected "+A.u(p)+" parameters, got "+A.u(n),null))
a.e=this
for(p=this.c,m=v.G,l=t.Z,k=t.V,j=0;j<n;j=g){i=p[j]
h=i>=8?B.n:B.C[i]
g=j+1
f=o[j]
switch(h.a){case 1:i=q.sqlite3_bind_int64(s,g,m.BigInt(A.Y(A.by(f))))
if(i!==0)a.a2(i,c)
break
case 2:i=q.sqlite3_bind_int64(s,g,k.a(f))
if(i!==0)a.a2(i,c)
break
case 3:i=q.sqlite3_bind_double(s,g,A.by(f))
if(i!==0)a.a2(i,c)
break
case 4:e=B.e.ag(A.dE(f))
i=q.dart_sqlite3_bind_text(s,g,r.cn(e),e.length)
if(i!==0)a.a2(i,c)
break
case 5:l.a(f)
i=q.dart_sqlite3_bind_blob(s,g,r.cn(f),f.length)
if(i!==0)a.a2(i,c)
break
case 6:i=q.sqlite3_bind_null(s,g)
if(i!==0)a.a2(i,c)
break
case 7:d=A.bx(f)?1:0
i=q.sqlite3_bind_int64(s,g,m.BigInt(d))
if(i!==0)a.a2(i,c)
break
case 0:throw A.b(A.bk("Unknown type code"))}}},
gk(a){return this.a.length},
n(a,b){var s=this.c[b],r=s>=8?B.n:B.C[s]
return r.fD(this.a[b])},
q(a,b,c){this.fn()},
fn(){throw A.b(A.bk("decodeValues list is unmodifiable"))}}
A.kq.prototype={
$1(a){this.b.transaction.abort()
this.a.a=!1},
$S:8}
A.fn.prototype={
$1(a){this.a.B(this.c.a(this.b.result))},
$S:1}
A.fo.prototype={
$1(a){var s=this.b.error
if(s==null)s=a
this.a.H(s)},
$S:1}
A.fr.prototype={
$1(a){this.a.B(this.c.a(this.b.result))},
$S:1}
A.fs.prototype={
$1(a){var s=this.b.error
if(s==null)s=a
this.a.H(s)},
$S:1}
A.ft.prototype={
$1(a){var s=this.b.error
if(s==null)s=a
this.a.H(s)},
$S:1}
A.hI.prototype={
h4(){var s,r,q,p
for(s=this.b,r=new A.bK(s,s.r,s.e);r.j();){q=r.d
if(!q.r){q.r=!0
if(!q.f){p=q.a
p.c.d.sqlite3_reset(p.b)
q.f=!0}q=q.a
p=q.c
p.d.sqlite3_finalize(q.b)
p=p.w
if(p!=null){p=p.a
if(p!=null)p.unregister(q.d)}}}s.V(0)}}
A.cB.prototype={
Y(){return"FileType."+this.b}}
A.aU.prototype={
Y(){return"StorageMode."+this.b}}
A.cU.prototype={
i(a){return"Remote error: "+this.a}}
A.b3.prototype={}
A.kg.prototype={
$1(a){return A.Z(a.data)},
$S:65}
A.dw.prototype={
p(){var s=this.a
if(s!=null)s.p()
this.a=null}}
A.c1.prototype={
m(){var s=0,r=A.i(t.H),q=this,p,o,n
var $async$m=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:q.c.p()
q.d.p()
q.e.p()
for(p=q.w,o=p.length,n=0;n<p.length;p.length===o||(0,A.T)(p),++n)p[n].abort()
B.c.V(p)
p=q.f
if(p!=null)p.b.L()
s=2
return A.c(q.a.b3(),$async$m)
case 2:return A.f(null,r)}})
return A.h($async$m,r)},
du(a){var s=new v.G.AbortController()
a.onabort=A.kh(new A.iV(s))
this.w.push(s)
return s},
bO(a,b,c,d){var s,r,q,p=this,o=null
if(a==null){s=p.a.f
if(!s.gfA()){r=p.du(b)
o=s.cz(c,r.signal,d).J(new A.iZ(p,r))}}else{s=p.f
if((s==null?null:s.a)!==a)throw A.b(A.x("Requested operation on inactive lock state."))}if(o==null)o=A.e7(c,d)
q=p.a.z
return q instanceof A.aP?o.J(q.ghb()):o},
hH(a){var s=this,r=s.du(a),q=new A.k($.l,t.B),p=new A.au(q,t.bS),o=t.H
A.kO(s.a.f.cz(new A.iW(s,p),r.signal,o),new A.iX(p),o,t.K)
return q.J(new A.iY(s,r))}}
A.iV.prototype={
$0(){return this.a.abort()},
$S:0}
A.iZ.prototype={
$0(){B.c.u(this.a.w,this.b)},
$S:2}
A.iW.prototype={
$0(){var s=this.a,r=s.r++,q=new A.k($.l,t.D)
s.f=new A.W(r,new A.au(q,t.h))
this.b.B(r)
return q},
$S:5}
A.iX.prototype={
$2(a,b){var s=this.a
if((s.a.a&30)===0)s.af(a,b)},
$S:11}
A.iY.prototype={
$0(){B.c.u(this.a.w,this.b)},
$S:2}
A.c_.prototype={
eu(a,b,c){this.b.a.J(new A.iJ(this))},
aA(a,b){return this.eN(a,b)},
eN(a,b){var s=0,r=A.i(t.m),q,p=this
var $async$aA=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:s=3
return A.c(p.w.dJ(a),$async$aA)
case 3:q={r:d.ge5(),i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$aA,r)},
cr(a,b){return this.hf(a,b)},
hf(a,b){var s=0,r=A.i(t.m),q,p=this,o,n
var $async$cr=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:n=p.w.gdf()
n.toString
o={r:a.r,i:0,d:null,t:"connect"}
n.a.postMessage(o,A.ck(o))
q={r:null,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$cr,r)},
aF(a,b){return this.hg(a,b)},
hg(a,b){var s=0,r=A.i(t.m),q,p=this,o,n,m,l,k
var $async$aF=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:k=a.d
s=k!=null?3:5
break
case 3:o=p.d5(k)
n=a.z
m=a.r
s=7
return A.c(o.a.ga1(),$async$aF)
case 7:s=6
return A.c(d.aG(p,new A.fx(new A.iM(o,n,b),m)),$async$aF)
case 6:l=d
s=4
break
case 5:s=8
return A.c(p.w.b.aG(p,new A.dY(a)),$async$aF)
case 8:l=d
case 4:q={r:l,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$aF,r)},
bz(a,b){return this.hp(a,b)},
hp(a,b){var s=0,r=A.i(t.m),q,p=this
var $async$bz=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:s=3
return A.c(p.w.y.cG(new A.iP(p,a),t.m),$async$bz)
case 3:q=d
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$bz,r)},
bC(a,b){return this.hs(a,b)},
hs(a,b){var s=0,r=A.i(t.m),q,p=this,o,n,m
var $async$bC=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:o=p.O(a)
n=o.a
s=3
return A.c(n.ga1(),$async$bC)
case 3:m=d
q=o.bO(a.z,b,new A.iS(m,a,n),t.m)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$bC,r)},
by(a,b){return this.hj(a,b)},
hj(a,b){var s=0,r=A.i(t.m),q,p=this
var $async$by=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:s=3
return A.c(p.O(a).hH(b),$async$by)
case 3:q={r:d,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$by,r)},
bx(a,b){return this.he(a,b)},
he(a,b){var s=0,r=A.i(t.m),q,p=this,o,n
var $async$bx=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:o=p.O(a)
n=o.e
s=a.a?3:5
break
case 3:s=6
return A.c(p.aq(n,new A.iL(p,o),a),$async$bx)
case 6:q=d
s=1
break
s=4
break
case 5:n.p()
q={r:null,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 4:case 1:return A.f(q,r)}})
return A.h($async$bx,r)},
bB(a,b){return this.hr(a,b)},
hr(a,b){var s=0,r=A.i(t.m),q,p=this,o,n
var $async$bB=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:o=p.O(a)
n=o.d
s=a.a?3:5
break
case 3:s=6
return A.c(p.aq(n,new A.iR(p,o),a),$async$bB)
case 6:q=d
s=1
break
s=4
break
case 5:n.p()
q={r:null,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 4:case 1:return A.f(q,r)}})
return A.h($async$bB,r)},
bD(a,b){return this.ht(a,b)},
ht(a,b){var s=0,r=A.i(t.m),q,p=this,o,n
var $async$bD=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:o=p.O(a)
n=o.c
s=a.a?3:5
break
case 3:s=6
return A.c(p.aq(n,new A.iU(p,o),a),$async$bD)
case 6:q=d
s=1
break
s=4
break
case 5:n.p()
q={r:null,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 4:case 1:return A.f(q,r)}})
return A.h($async$bD,r)},
bA(a,b){return this.hq(a,b)},
hq(a,b){var s=0,r=A.i(t.m),q,p=this,o,n,m
var $async$bA=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:m=p.O(a).a;++m.w
s=3
return A.c(A.kr(),$async$bA)
case 3:o=d
n=o.a
p.w.cU(o.b).x.push(A.m2(m,0))
q={r:n,i:a.i,t:"endpointResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$bA,r)},
bw(a,b){return this.hd(a,b)},
hd(a,b){var s=0,r=A.i(t.m),q,p=this,o
var $async$bw=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:o=p.O(a)
B.c.u(p.x,o)
s=3
return A.c(o.m(),$async$bw)
case 3:q={r:null,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$bw,r)},
b6(a,b){return this.hm(a,b)},
hm(a,b){var s=0,r=A.i(t.m),q,p=this,o
var $async$b6=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:s=3
return A.c(p.O(a).a.ga8(),$async$b6)
case 3:o=d
s=o instanceof A.aP?4:5
break
case 4:s=6
return A.c(o.dU(),$async$b6)
case 6:case 5:q={r:null,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$b6,r)},
b4(a,b){return this.hk(a,b)},
hk(a,b){var s=0,r=A.i(t.m),q,p=this,o,n,m,l,k,j
var $async$b4=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:o=p.O(a)
n=B.D[a.f]
m=a.b
l=o
k=b
j=A
s=4
return A.c(o.a.ga8(),$async$b4)
case 4:s=3
return A.c(l.bO(null,k,new j.iN(d,n,m,a),t.m),$async$b4)
case 3:q=d
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$b4,r)},
b5(a,b){return this.hl(a,b)},
hl(a,b){var s=0,r=A.i(t.m),q,p=this,o,n,m,l
var $async$b5=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:o=p.O(a)
n=o
m=b
l=A
s=4
return A.c(o.a.ga8(),$async$b5)
case 4:s=3
return A.c(n.bO(null,m,new l.iO(d,a),t.y),$async$b5)
case 3:q={r:d,i:a.i,t:"simpleSuccessResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$b5,r)},
aq(a,b,c){return this.em(a,b,c)},
em(a,b,c){var s=0,r=A.i(t.m),q,p
var $async$aq=A.j(function(d,e){if(d===1)return A.e(e,r)
for(;;)switch(s){case 0:s=a.a==null?3:4
break
case 3:p=a
s=5
return A.c(b.$0(),$async$aq)
case 5:p.a=e
case 4:q={r:null,i:c.i,t:"simpleSuccessResponse"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$aq,r)},
ho(a){},
br(a){var s=0,r=A.i(t.X),q,p=this
var $async$br=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:s=3
return A.c(p.bi({r:a,z:null,i:0,d:null,t:"custom"},B.ad,t.m),$async$br)
case 3:q=c.r
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$br,r)},
d5(a){return B.c.dT(this.x,new A.iI(a))},
O(a){var s=a.d
if(s!=null)return this.d5(s)
else throw A.b(A.a0("Request requires database id",null))},
$ilv:1}
A.iJ.prototype={
$0(){var s=0,r=A.i(t.H),q=this,p,o,n
var $async$$0=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:p=q.a.x,o=p.length,n=0
case 2:if(!(n<p.length)){s=4
break}s=5
return A.c(p[n].m(),$async$$0)
case 5:case 3:p.length===o||(0,A.T)(p),++n
s=2
break
case 4:B.c.V(p)
return A.f(null,r)}})
return A.h($async$$0,r)},
$S:5}
A.iM.prototype={
$1$1(a,b){return this.a.bO(this.b,this.c,a,b)},
$1(a){return this.$1$1(a,t.z)},
$S:66}
A.iP.prototype={
$0(){var s=0,r=A.i(t.m),q,p=2,o=[],n=this,m,l,k,j,i,h,g
var $async$$0=A.j(function(a,b){if(a===1){o.push(b)
s=p}for(;;)switch(s){case 0:j=n.a
i=j.w
h=n.b
s=3
return A.c(i.a0(h.u),$async$$0)
case 3:m=null
l=null
p=5
m=i.ha(h.d,A.nA(h.s),h.c,h.a)
s=8
return A.c(h.o?m.ga8():m.ga1(),$async$$0)
case 8:l=A.m2(m,null)
j.x.push(l)
i={r:m.b,i:h.i,t:"simpleSuccessResponse"}
q=i
s=1
break
p=2
s=7
break
case 5:p=4
g=o.pop()
s=m!=null?9:10
break
case 9:B.c.u(j.x,l)
s=11
return A.c(m.b3(),$async$$0)
case 11:case 10:throw g
s=7
break
case 4:s=2
break
case 7:case 1:return A.f(q,r)
case 2:return A.e(o.at(-1),r)}})
return A.h($async$$0,r)},
$S:67}
A.iS.prototype={
$0(){var s,r,q,p,o=null,n="This database has already been closed",m=this.a.a,l=this.b
if(l.c&&m.gb2())throw A.b(A.x("Database is not in a transaction"))
s=l.p
r=l.v
r.toString
q=new A.aN(s,r,A.ag(r,0,o))
s=this.c
if(l.r){p=s.ee(m,l.s,q)
p.i=l.i
p.x=m.gb2()
if(m.r)A.y(A.x(n))
l=m.b
p.y=A.Y(v.G.Number(l.a.d.sqlite3_last_insert_rowid(l.b)))
return p}else{s.h7(m,l.s,q)
s=m.gb2()
if(m.r)A.y(A.x(n))
r=m.b
return A.mD(s,o,A.Y(v.G.Number(r.a.d.sqlite3_last_insert_rowid(r.b))),l.i,o,o,o)}},
$S:16}
A.iL.prototype={
$0(){var s=0,r=A.i(t.w),q,p=this,o
var $async$$0=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:o=p.b
s=3
return A.c(o.a.ga1(),$async$$0)
case 3:q=b.a.c_().gaQ().ai(new A.iK(p.a,o))
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$$0,r)},
$S:25}
A.iK.prototype={
$1(a){var s={d:this.b.b,t:"notifyCommit"}
this.a.a.postMessage(s,A.ck(s))},
$S:13}
A.iR.prototype={
$0(){var s=0,r=A.i(t.w),q,p=this,o
var $async$$0=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:o=p.b
s=3
return A.c(o.a.ga1(),$async$$0)
case 3:q=b.a.ff().gaQ().ai(new A.iQ(p.a,o))
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$$0,r)},
$S:25}
A.iQ.prototype={
$1(a){var s={d:this.b.b,t:"notifyRollback"}
this.a.a.postMessage(s,A.ck(s))},
$S:13}
A.iU.prototype={
$0(){var s=0,r=A.i(t.aY),q,p=this,o
var $async$$0=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:o=p.b
s=3
return A.c(o.a.ga1(),$async$$0)
case 3:q=b.a.dC().gaQ().ai(new A.iT(p.a,o))
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$$0,r)},
$S:70}
A.iT.prototype={
$1(a){var s={k:a.a.a,u:a.b,r:a.c,d:this.b.b,t:"notifyUpdate"}
this.a.a.postMessage(s,A.ck(s))},
$S:26}
A.iN.prototype={
$0(){var s,r,q,p=this,o=p.a.ap(new A.cW(A.mk(p.b)),4).a
try{q=p.c
if(q!=null){s=q
o.bg(s.byteLength)
o.aN(A.ag(s,0,null),0)
q={r:null,i:p.d.i,t:"simpleSuccessResponse"}
return q}else{q=o.aM()
r=new Uint8Array(q)
o.bT(r,0)
q={r:t.a.a(J.na(r)),i:p.d.i,t:"simpleSuccessResponse"}
return q}}finally{o.bR()}},
$S:16}
A.iO.prototype={
$0(){return this.a.bQ(A.mk(B.D[this.b.f]),0)===1},
$S:72}
A.iI.prototype={
$1(a){return a.b===this.a},
$S:73}
A.e0.prototype={
ga8(){var s=0,r=A.i(t.fL),q,p=this,o
var $async$ga8=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:o=p.y
s=3
return A.c(o==null?p.y=A.e7(new A.hc(p),t.H):o,$async$ga8)
case 3:o=p.z
o.toString
q=o
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$ga8,r)},
ga1(){var s=0,r=A.i(t.u),q,p=this,o
var $async$ga1=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:o=p.x
s=3
return A.c(o==null?p.x=A.e7(new A.hb(p),t.u):o,$async$ga1)
case 3:q=b
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$ga1,r)},
b3(){var s=0,r=A.i(t.H),q=this
var $async$b3=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:s=--q.w===0?2:3
break
case 2:s=4
return A.c(q.m(),$async$b3)
case 4:case 3:return A.f(null,r)}})
return A.h($async$b3,r)},
m(){var s=0,r=A.i(t.H),q=this,p,o,n,m,l,k,j
var $async$m=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:j=q.a.r
j.toString
s=2
return A.c(j,$async$m)
case 2:p=b
o=q.x
s=o!=null?3:4
break
case 3:s=5
return A.c(o,$async$m)
case 5:n=b
j=q.r
if(j!=null)j.h4()
n.a.m()
m=q.z
if(m!=null){j=p.a
l=j.b
A.lz(m)
k=l.a.get(m)
if(k==null)A.y(A.x("vfs has not been registered"))
l.q(0,m,null)
j.a.d.dart_sqlite3_unregister_vfs(k)}case 4:j=q.Q
j=j==null?null:j.$0()
s=6
return A.c(j instanceof A.k?j:A.c8(j,t.H),$async$m)
case 6:q.f.e3()
return A.f(null,r)}})
return A.h($async$m,r)},
di(a,b){var s,r,q,p,o=this.r,n=o==null
if(n)s=null
else{r=o.b
q=r.u(0,b)
if(q!=null)r.q(0,b,q)
s=q}if(s!=null)return new A.W(s,!0)
p=a.e0(b,!0)
if(!n){p.bl()
n=p.a
n=n.c.d.sqlite3_stmt_isexplain(n.b)===0}else n=!1
if(n){n=o.b
if(n.a===o.a)n.u(0,new A.aB(n,A.A(n).h("aB<1>")).ga6(0)).m()
n.q(0,p.d,p)
return new A.W(p,!0)}return new A.W(p,!1)},
h7(a,b,c){var s,r,q
if(c.gk(0)===0)return a.h6(b,B.aa)
else{s=null
r=null
q=this.di(a,b)
s=q.a
r=q.b
try{s.h8(new A.cx(c.gdH()))}finally{if(r)s.bc()
else s.m()}}},
ee(a,b,c){var s,r=null,q=null,p=this.di(a,b)
r=p.a
q=p.b
try{s=A.o5(r,c)
return s}finally{if(q)r.bc()
else r.m()}}}
A.hc.prototype={
$0(){var s=0,r=A.i(t.H),q=this,p,o,n,m,l,k
var $async$$0=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:l=q.a
k=l.d
case 2:switch(k.a){case 0:s=4
break
case 1:s=5
break
case 2:s=6
break
case 3:s=7
break
case 4:s=8
break
default:s=3
break}break
case 4:s=9
return A.c(A.hT("drift_db/"+l.c,"vfs-web-"+l.b),$async$$0)
case 9:p=b
l.z=p
l.Q=p.gbp()
s=3
break
case 5:case 6:s=10
return A.c(A.e6("drift_db/"+l.c,k===B.l,"vfs-web-"+l.b),$async$$0)
case 10:o=b
l.f.e=o
n=o.a
l.z=n
l.Q=n.gbp()
s=3
break
case 7:s=11
return A.c(A.ea(l.c,"vfs-web-"+l.b,!1),$async$$0)
case 11:m=b
l.z=m
l.Q=m.gbp()
s=3
break
case 8:l.z=A.kP("vfs-web-"+l.b,null)
s=3
break
case 3:return A.f(null,r)}})
return A.h($async$$0,r)},
$S:5}
A.hb.prototype={
$0(){var s=0,r=A.i(t.u),q,p=this,o,n,m,l,k,j
var $async$$0=A.j(function(a,b){if(a===1)return A.e(b,r)
for(;;)switch(s){case 0:k=p.a
j=k.a.r
j.toString
s=3
return A.c(j,$async$$0)
case 3:o=b
s=4
return A.c(k.ga8(),$async$$0)
case 4:n=b
o.dX()
j=o.a
m=j.b
A.lz(n)
if(m.a.get(n)!=null)A.y(A.x("vfs has already been registered"))
j=j.a
l=j.d.dart_sqlite3_register_vfs(j.b1(B.e.ag(n.a),1),n,0)
if(l===0)A.y(A.x("could not register vfs"))
m.q(0,n,l)
s=5
return A.c(k.f.cz(new A.ha(k,o),null,t.u),$async$$0)
case 5:q=b
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$$0,r)},
$S:27}
A.ha.prototype={
$0(){var s=this.a
return s.a.b.cA(this.b,"/database","vfs-web-"+s.b,s.e)},
$S:27}
A.ix.prototype={
gdf(){var s,r=this,q=r.Q
if(q===$){s=r.a.b.ei()
r.Q!==$&&A.qv()
r.Q=s
q=s}return q},
aH(){var s=0,r=A.i(t.H),q=1,p=[],o=[],n=this,m,l,k,j,i,h
var $async$aH=A.j(function(a,b){if(a===1){p.push(b)
s=q}for(;;)switch(s){case 0:h=new A.bv(A.dJ(A.p5(n.a),"stream",t.K))
q=2
j=v.G
case 5:s=7
return A.c(h.j(),$async$aH)
case 7:if(!b){s=6
break}m=h.gl()
s=J.N(m.t,"connect")?8:10
break
case 8:i=m.r
l=new A.cu(i.port,i.lockName,null)
n.cU(l)
s=9
break
case 10:s=A.qk(m.t)?11:12
break
case 11:s=13
return A.c(n.dJ(m),$async$aH)
case 13:k=b
j.postMessage(k.ge5())
case 12:case 9:s=5
break
case 6:o.push(4)
s=3
break
case 2:o=[1]
case 3:q=1
s=14
return A.c(h.p(),$async$aH)
case 14:s=o.pop()
break
case 4:return A.f(null,r)
case 1:return A.e(p.at(-1),r)}})
return A.h($async$aH,r)},
cU(a){var s=this,r=A.om(a,s.d++,s)
s.c.push(r)
r.b.a.J(new A.iy(s,r))
return r},
dJ(a){return this.x.cG(new A.iz(this,a),t.d)},
a0(a){return this.hB(a)},
hB(a){var s=0,r=A.i(t.H),q=this,p,o,n,m
var $async$a0=A.j(function(b,c){if(b===1)return A.e(c,r)
for(;;)switch(s){case 0:n=v.G
m=new n.URL(a,A.Z(n.location).href).href
n=q.r
s=n!=null?2:4
break
case 2:p=q.w
if(p!==m)throw A.b(A.x("Workers only support a single sqlite3 wasm module, provided different URI (has "+A.u(p)+", got "+m+")"))
s=5
return A.c(t.bU.b(n)?n:A.c8(n,t.ex),$async$a0)
case 5:s=3
break
case 4:o=A.kO(q.b.a0(m),new A.iA(q),t.n,t.K)
q.r=o
s=6
return A.c(o,$async$a0)
case 6:q.w=m
case 3:return A.f(null,r)}})
return A.h($async$a0,r)},
ha(a,b,c,d){var s,r,q,p,o,n
for(s=this.e,r=new A.bK(s,s.r,s.e);r.j();){q=r.d
p=q.w
if(p!==0&&q.c===a&&q.d===b){q.w=p+1
return q}}r=this.f++
q="pkg-sqlite3-web-"+a
p=b===B.l||b===B.z
o=A.kT(t.L)
n=c===0?null:new A.hI(c,A.nT(t.N,t.eT))
n=new A.e0(this,r,a,b,d,new A.e_(q+"-outer",q,new A.cM(o),p),n)
s.q(0,r,n)
return n}}
A.iy.prototype={
$0(){var s=this.a,r=s.c
B.c.u(r,this.b)
if(r.length===0)s.a.m()
return null},
$S:0}
A.iz.prototype={
$0(){var s=0,r=A.i(t.d),q,p=this,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a
var $async$$0=A.j(function(a0,a1){if(a0===1)return A.e(a1,r)
for(;;)switch(s){case 0:d=p.b
c=d.d
s=J.N(d.t,"dedicatedCompatibilityCheck")||J.N(d.t,"dedicatedInSharedCompatibilityCheck")?3:5
break
case 3:s=6
return A.c(A.b0(),$async$$0)
case 6:o=a1
n=o.a
m=o.b
l=m
k=n
s=4
break
case 5:k=!1
l=!1
case 4:b=J.N(d.t,"dedicatedCompatibilityCheck")||J.N(d.t,"sharedCompatibilityCheck")
if(b){s=7
break}else a1=b
s=8
break
case 7:s=9
return A.c(A.f7(),$async$$0)
case 9:case 8:j=a1
i=A.cI(t.ab)
s=J.N(d.t,"sharedCompatibilityCheck")?10:12
break
case 10:h=p.a.gdf()
g=h!=null
s=g?13:14
break
case 13:d={d:c,i:0,t:"dedicatedInSharedCompatibilityCheck"}
f=A.ck(d)
n=h.a
n.postMessage(d,f)
b=A
a=A
s=15
return A.c(new A.c6(n,"message",!1,t.Y).ga6(0),$async$$0)
case 15:e=b.no(a.Z(a1.data))
k=e.c
l=e.d
i.a4(0,e.a)
case 14:s=11
break
case 12:g=!1
case 11:s=k?16:17
break
case 16:b=J
s=18
return A.c(A.cm(),$async$$0)
case 18:d=b.ak(a1)
case 19:if(!d.j()){s=20
break}i.E(0,new A.W(B.G,d.gl()))
s=19
break
case 20:case 17:s=j&&c!=null?21:22
break
case 21:s=23
return A.c(A.kp(c),$async$$0)
case 23:if(a1)i.E(0,new A.W(B.H,c))
case 22:d=A.cK(i,i.$ti.c)
q=new A.b9(d,g,k,l,j)
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$$0,r)},
$S:75}
A.iA.prototype={
$2(a,b){this.a.r=null
throw A.b(a)},
$S:76}
A.dC.prototype={}
A.eG.prototype={
gdW(){return new A.c6(this.a,"message",!1,t.Y)},
m(){return this.a.close()}}
A.eW.prototype={
gdW(){return new A.aI(new A.jN(this),t.c3)},
m(){}}
A.jN.prototype={
$1(a){var s=A.v([],t.W),r=A.v([],t.db)
r.push(A.a2(this.a.a,"connect",new A.jK(new A.jO(s,r,a)),!1,t.m))
a.r=new A.jL(r)},
$S:77}
A.jO.prototype={
$1(a){this.a.push(a)
a.start()
this.b.push(A.a2(a,"message",new A.jM(this.c),!1,t.m))},
$S:1}
A.jM.prototype={
$1(a){this.a.fw(a)},
$S:1}
A.jK.prototype={
$1(a){var s,r=a.ports
r=J.ak(t.q.b(r)?r:new A.ay(r,A.aw(r).h("ay<1,m>")))
s=this.a
while(r.j())s.$1(r.gl())},
$S:1}
A.jL.prototype={
$0(){var s,r,q
for(s=this.a,r=s.length,q=0;q<s.length;s.length===r||(0,A.T)(s),++q)s[q].p()},
$S:2}
A.eH.prototype={
ei(){var s=v.G
if(!("Worker" in s))return null
return new A.j4(new s.Worker(this.a,{name:"sqlite3_worker"}))}}
A.j4.prototype={}
A.ia.prototype={
$1(a){this.a.E(0,a.b)},
$S:26}
A.i7.prototype={
$0(){var s,r,q,p,o,n,m,l,k,j,i
for(s=this.a,r=s.length,q=this.b,p=t.N,o=0;o<s.length;s.length===r||(0,A.T)(s),++o){n=s[o]
n.b.a4(0,q)
m=n.a
l=m.b
k=(l&1)!==0
if(!(k?(m.gP().e&4)!==0:(l&2)===0)){j=n.b
if(j.a!==0){if(l>=4)A.y(m.ab())
if(k)m.ac(j)
else if((l&3)===0){m=m.aV()
j=new A.aY(j)
i=m.c
if(i==null)m.b=m.c=j
else{i.saj(j)
m.c=j}}n.b=A.cI(p)}}}q.V(0)},
$S:0}
A.i8.prototype={
$0(){this.a.V(0)},
$S:0}
A.i4.prototype={
$1(a){var s,r,q=this,p=q.b
p.push(a)
if(p.length===1){p=q.c
s=p.dC()
r=s.w
s=r==null?s.w=s.dc(!0):r
q.a.a=A.v([s.ai(q.d),p.c_().gaQ().ai(new A.i5(q.e)),p.c_().gaQ().ai(new A.i6(q.f))],t.x)}},
$S:17}
A.i5.prototype={
$1(a){return this.a.$0()},
$S:13}
A.i6.prototype={
$1(a){return this.a.$0()},
$S:13}
A.ib.prototype={
$1(a){var s,r,q=this.b
B.c.u(q,a)
if(q.length===0)for(q=this.a.a,s=q.length,r=0;r<q.length;q.length===s||(0,A.T)(q),++r)q[r].p()},
$S:17}
A.i9.prototype={
$1(a){var s=new A.bw(a,A.cI(t.N))
this.a.$1(s)
a.f=s.gfu()
a.r=new A.i3(this.b,s)},
$S:79}
A.i3.prototype={
$0(){return this.a.$1(this.b)},
$S:0}
A.bw.prototype={
fv(){var s=this.b
if(s.a!==0){this.a.E(0,s)
this.b=A.cI(t.N)}}}
A.aM.prototype={
Y(){return"CustomDatabaseMessageKind."+this.b}}
A.fd.prototype={
cA(a,b,c,d){return this.hL(a,b,c,d)},
hL(a,b,c,d){var s=0,r=A.i(t.u),q,p
var $async$cA=A.j(function(e,f){if(e===1)return A.e(f,r)
for(;;)switch(s){case 0:p=a.hJ(b,c)
q=new A.dP(p,A.oa(p),A.aC(t.fg,t.bD))
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$cA,r)},
aG(a,b){throw A.b(A.l_(null))}}
A.dP.prototype={
fc(a,b){if(!a.a){a.a=!0
b.b.a.bf(new A.fe(a),t.P)}},
aG(a,b){return this.hh(a,b)},
hh(a,b){var s=0,r=A.i(t.X),q,p=this,o,n,m,l,k
var $async$aG=A.j(function(c,d){if(c===1)return A.e(d,r)
for(;;)switch(s){case 0:k=A.Z(b.a)
case 3:switch(A.ly(B.a8,k.rawKind).a){case 0:s=5
break
case 4:s=6
break
case 1:s=7
break
case 2:s=8
break
case 3:s=9
break
default:s=4
break}break
case 5:case 6:throw A.b(A.bk("This is a response, not a request"))
case 7:q=p.a.gb2()
s=1
break
case 8:s=10
return A.c(b.c.$1$1(new A.ff(p,k),t.P),$async$aG)
case 10:s=4
break
case 9:o=k.rawParameters
n=A.bx(o[0])
o=k.rawSql
m=p.c.e1(a,A.qx())
if(n){m.cF()
p.fc(m,a)
l=A.ol()
l.b=m.b=p.b.ai(new A.fg(l,a,o))}else m.cF()
s=4
break
case 4:q={rawKind:"ok"}
s=1
break
case 1:return A.f(q,r)}})
return A.h($async$aG,r)}}
A.fe.prototype={
$1(a){this.a.cF()},
$S:80}
A.ff.prototype={
$0(){var s,r,q,p,o,n,m,l=null,k=this.b
if(k.requireTransaction&&this.a.a.gb2())throw A.b(A.lW(A.nP(A.kv(k,"rawSql")),l,0,"Transaction rolled back by earlier statement. Cannot execute",l,l,l))
s=this.a.a.hN(k.rawSql)
try{k=k.parameters
k=J.ak(t.q.b(k)?k:new A.ay(k,A.aw(k).h("ay<1,m>")))
while(k.j()){r=k.gl()
q=s
p=r
o=p.parameters
p=p.parameterTypes
p.toString
n=new Uint8Array(p,0)
if(q.r||q.b.r)A.y(A.x(u.n))
if(!q.f){m=q.a
m.c.d.sqlite3_reset(m.b)
q.f=!0}q.cX(new A.cx(new A.aN(o,p,n).gdH()))
q.d9()}}finally{s.m()}},
$S:2}
A.fg.prototype={
$1(a){var s,r=this.a,q=r.b
if(q===r)A.y(new A.bb("Local '"+r.a+"' has not been initialized."))
r=A.cK(a,a.$ti.c)
s=A.m_(r)
q.bM(this.b.br({rawKind:"notifyUpdates",rawSql:this.c,rawParameters:s.a,typeInfo:s.b}))},
$S:81}
A.c2.prototype={
cF(){var s=this.b
if(s!=null){this.b=null
s.p()}}}
A.bV.prototype={
gk(a){return this.b},
n(a,b){if(b>=this.b)throw A.b(A.lE(b,this))
return this.a[b]},
q(a,b,c){var s
if(b>=this.b)throw A.b(A.lE(b,this))
s=this.a
s.$flags&2&&A.E(s)
s[b]=c},
sk(a,b){var s,r,q,p,o=this,n=o.b
if(b<n)for(s=o.a,r=s.$flags|0,q=b;q<n;++q){r&2&&A.E(s)
s[q]=0}else{n=o.a.length
if(b>n){if(n===0)p=new Uint8Array(b)
else p=o.eH(b)
B.d.R(p,0,o.b,o.a)
o.a=p}}o.b=b},
eH(a){var s=this.a.length*2
if(a!=null&&s<a)s=a
else if(s<8)s=8
return new Uint8Array(s)},
D(a,b,c,d,e){var s=this.b
if(c>s)throw A.b(A.ac(c,0,s,null,null))
B.d.D(this.a,b,c,d,e)},
R(a,b,c,d){return this.D(0,b,c,d,0)}}
A.eO.prototype={}
A.at.prototype={}
A.kN.prototype={}
A.c6.prototype={
I(a,b,c,d){return A.a2(this.a,this.b,a,!1,this.$ti.c)},
b8(a,b,c){return this.I(a,null,b,c)}}
A.dc.prototype={
p(){var s=this,r=A.hn(null,t.H)
if(s.b==null)return r
s.ck()
s.d=s.b=null
return r},
dZ(a){var s,r=this
if(r.b==null)throw A.b(A.x("Subscription has been canceled."))
r.ck()
s=A.mv(new A.j8(a),t.m)
s=s==null?null:A.ax(s)
r.d=s
r.ci()},
bM(a){if(this.b==null)return;++this.a
this.ck()},
bL(){return this.bM(null)},
aL(){var s=this
if(s.b==null||s.a<=0)return;--s.a
s.ci()},
ci(){var s=this,r=s.d
if(r!=null&&s.a<=0)s.b.addEventListener(s.c,r,!1)},
ck(){var s=this.d
if(s!=null)this.b.removeEventListener(this.c,s,!1)},
$iai:1}
A.j7.prototype={
$1(a){return this.a.$1(a)},
$S:1}
A.j8.prototype={
$1(a){return this.a.$1(a)},
$S:1};(function aliases(){var s=J.aR.prototype
s.en=s.i
s=A.ad.prototype
s.eo=s.av
s.ep=s.aR
s=A.t.prototype
s.cS=s.D})();(function installTearOffs(){var s=hunkHelpers._static_2,r=hunkHelpers._static_1,q=hunkHelpers._static_0,p=hunkHelpers.installStaticTearOff,o=hunkHelpers._instance_2u,n=hunkHelpers.installInstanceTearOff,m=hunkHelpers._instance_0u,l=hunkHelpers._instance_1u
s(J,"pd","nM",82)
r(A,"pO","oi",7)
r(A,"pP","oj",7)
r(A,"pQ","ok",7)
r(A,"pR","pr",83)
q(A,"mx","pI",0)
r(A,"pS","ps",9)
s(A,"pU","pu",10)
q(A,"pT","pt",0)
p(A,"pX",5,null,["$5"],["pC"],84,0)
p(A,"q1",4,null,["$1$4","$4"],["kl",function(a,b,c,d){return A.kl(a,b,c,d,t.z)}],85,0)
p(A,"q3",5,null,["$2$5","$5"],["km",function(a,b,c,d,e){var j=t.z
return A.km(a,b,c,d,e,j,j)}],86,0)
p(A,"q2",6,null,["$3$6"],["lb"],87,0)
p(A,"q_",4,null,["$1$4","$4"],["mr",function(a,b,c,d){return A.mr(a,b,c,d,t.z)}],88,0)
p(A,"q0",4,null,["$2$4","$4"],["ms",function(a,b,c,d){var j=t.z
return A.ms(a,b,c,d,j,j)}],89,0)
p(A,"pZ",4,null,["$3$4","$4"],["mq",function(a,b,c,d){var j=t.z
return A.mq(a,b,c,d,j,j,j)}],90,0)
p(A,"pV",5,null,["$5"],["pB"],91,0)
p(A,"q4",4,null,["$4"],["kn"],92,0)
p(A,"r6",5,null,["$5"],["pA"],93,0)
p(A,"r5",5,null,["$5"],["pz"],94,0)
p(A,"pY",4,null,["$4"],["pD"],95,0)
p(A,"pW",5,null,["$5"],["mp"],96,0)
o(A.k.prototype,"gd2","eD",10)
n(A.bu.prototype,"gfs",0,1,null,["$2","$1"],["dE","ft"],32,0,0)
var k
m(k=A.c4.prototype,"gcb","aB",0)
m(k,"gcc","aC",0)
m(k=A.ad.prototype,"ghO","aL",0)
m(k,"gcb","aB",0)
m(k,"gcc","aC",0)
l(k=A.bv.prototype,"gf0","f1",19)
o(k,"gf4","f5",10)
m(k,"gf2","f3",0)
m(k=A.c7.prototype,"gcb","aB",0)
m(k,"gcc","aC",0)
l(k,"geO","eP",19)
o(k,"geT","eU",28)
m(k,"geR","eS",0)
l(k=A.dZ.prototype,"ghE","hF",4)
o(k,"ghC","hD",74)
n(k,"gij",0,5,null,["$5"],["ik"],78,0,0)
n(k,"gi4",0,3,null,["$3"],["i5"],29,0,0)
n(k,"ghX",0,4,null,["$4"],["hY"],22,0,0)
n(k,"gie",0,4,null,["$4"],["ig"],22,0,0)
n(k,"gil",0,3,null,["$3"],["im"],31,0,0)
o(k,"gir","is",20)
o(k,"gi2","i3",20)
l(k,"gi0","i1",14)
n(k,"gio",0,4,null,["$4"],["ip"],23,0,0)
n(k,"giz",0,4,null,["$4"],["iA"],23,0,0)
o(k,"giv","iw",35)
o(k,"git","iu",6)
o(k,"gi9","ia",6)
o(k,"gib","ic",6)
o(k,"gih","ii",6)
o(k,"gix","iy",6)
o(k,"ghZ","i_",6)
l(k,"gbS","i6",14)
n(k,"gi7",0,3,null,["$3"],["i8"],37,0,0)
l(k,"gbU","iq",14)
l(k,"gfR","fS",7)
l(k,"gfM","fN",38)
n(k,"gfP",0,5,null,["$5"],["fQ"],39,0,0)
n(k,"gfX",0,4,null,["$4"],["fY"],15,0,0)
n(k,"gh0",0,4,null,["$4"],["h1"],15,0,0)
n(k,"gfZ",0,4,null,["$4"],["h_"],15,0,0)
o(k,"gh2","h3",24)
o(k,"gfV","fW",24)
n(k,"gfT",0,5,null,["$5"],["fU"],42,0,0)
o(k,"gfK","fL",43)
o(k,"gfI","fJ",44)
n(k,"gfG",0,3,null,["$3"],["fH"],45,0,0)
m(k=A.aP.prototype,"gbp","m",5)
m(k,"ghb","dU",5)
m(A.bS.prototype,"gbp","m",0)
m(A.e_.prototype,"geW","eX",0)
l(A.aN.prototype,"gdH","dI",97)
l(A.c_.prototype,"ghn","ho",1)
m(A.bw.prototype,"gfu","fv",0)
q(A,"qx","on",64)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.d,null)
q(A.d,[A.kR,J.eb,A.cV,J.dM,A.q,A.dT,A.F,A.b7,A.hR,A.bL,A.ej,A.d5,A.eA,A.e3,A.cC,A.dq,A.cv,A.eP,A.ic,A.hG,A.cA,A.du,A.cL,A.hy,A.ei,A.bK,A.eh,A.iH,A.f1,A.am,A.eL,A.jW,A.f0,A.d7,A.eZ,A.H,A.df,A.c0,A.av,A.k,A.eD,A.O,A.bu,A.f_,A.eE,A.ad,A.eI,A.j5,A.dp,A.bv,A.k9,A.kb,A.ka,A.k7,A.k8,A.k6,A.k3,A.f4,A.k2,A.k1,A.k5,A.k4,A.f3,A.kc,A.f2,A.cf,A.d6,A.bR,A.jB,A.c9,A.eQ,A.X,A.t,A.eR,A.dV,A.dX,A.k_,A.cd,A.eK,A.e1,A.az,A.j6,A.es,A.cY,A.j9,A.hh,A.a6,A.z,A.eY,A.cZ,A.e4,A.hF,A.jy,A.jz,A.an,A.bT,A.fX,A.aZ,A.hV,A.b8,A.U,A.dQ,A.dS,A.hu,A.cx,A.aW,A.cW,A.is,A.im,A.iu,A.it,A.bm,A.bn,A.dZ,A.bq,A.io,A.fh,A.dg,A.ja,A.eS,A.eN,A.jD,A.ih,A.cu,A.hQ,A.dU,A.fW,A.dY,A.bo,A.e5,A.hq,A.aA,A.e_,A.cM,A.b9,A.hI,A.cU,A.dw,A.c1,A.e0,A.ix,A.dC,A.eH,A.j4,A.bw,A.c2,A.kN,A.dc])
q(J.eb,[J.ee,J.cF,J.I,J.a3,J.bJ,J.cG,J.aQ])
q(J.I,[J.aR,J.p,A.bN,A.cP])
q(J.aR,[J.et,J.bj,J.a9])
r(J.ed,A.cV)
r(J.hw,J.p)
q(J.cG,[J.cE,J.ef])
q(A.q,[A.aX,A.o,A.bd,A.d4,A.aF,A.dh,A.cb,A.bc])
q(A.aX,[A.b6,A.dD])
r(A.db,A.b6)
r(A.d8,A.dD)
r(A.ay,A.d8)
q(A.F,[A.bb,A.aG,A.eg,A.eC,A.ex,A.eJ,A.cS,A.dN,A.al,A.d1,A.eB,A.as,A.dW])
q(A.b7,[A.fl,A.fm,A.i2,A.kw,A.ky,A.iC,A.iB,A.kd,A.ho,A.hj,A.je,A.jd,A.jp,A.i_,A.hZ,A.j3,A.jJ,A.hA,A.hk,A.kD,A.kE,A.hW,A.h4,A.jR,A.kC,A.kF,A.kG,A.fc,A.j_,A.j0,A.fp,A.fq,A.fu,A.fv,A.fw,A.hg,A.fk,A.fi,A.js,A.jv,A.jw,A.ht,A.hr,A.jr,A.hU,A.ii,A.ij,A.ik,A.il,A.hN,A.hO,A.hM,A.hL,A.hK,A.iv,A.h7,A.hC,A.he,A.kq,A.fn,A.fo,A.fr,A.fs,A.ft,A.kg,A.iM,A.iK,A.iQ,A.iT,A.iI,A.jN,A.jO,A.jM,A.jK,A.ia,A.i4,A.i5,A.i6,A.ib,A.i9,A.fe,A.fg,A.j7,A.j8])
q(A.fl,[A.kB,A.iD,A.iE,A.jV,A.jU,A.jg,A.jl,A.jk,A.ji,A.jh,A.jo,A.jn,A.jm,A.i0,A.hY,A.jQ,A.jP,A.iG,A.iF,A.jE,A.jC,A.kf,A.j2,A.j1,A.jI,A.jH,A.kk,A.jZ,A.jY,A.h5,A.h6,A.h2,A.h1,A.h3,A.fZ,A.fY,A.h_,A.h0,A.jS,A.jT,A.kH,A.fH,A.fD,A.fM,A.fO,A.fR,A.fG,A.fF,A.fP,A.fV,A.fT,A.fS,A.fL,A.fK,A.fN,A.fU,A.fE,A.fI,A.fJ,A.fQ,A.fB,A.fC,A.fA,A.fz,A.fy,A.fa,A.fb,A.ip,A.fj,A.jt,A.ju,A.jb,A.hs,A.h8,A.h9,A.hE,A.hD,A.iV,A.iZ,A.iW,A.iY,A.iJ,A.iP,A.iS,A.iL,A.iR,A.iU,A.iN,A.iO,A.hc,A.hb,A.ha,A.iy,A.iz,A.jL,A.i7,A.i8,A.i3,A.ff])
q(A.o,[A.af,A.cz,A.aB,A.cH])
q(A.af,[A.d_,A.aD,A.cJ])
r(A.cy,A.bd)
r(A.bH,A.aF)
r(A.eT,A.dq)
q(A.eT,[A.W,A.dr,A.ds,A.ca,A.eU])
r(A.cw,A.cv)
r(A.cR,A.aG)
q(A.i2,[A.hX,A.cs])
r(A.ba,A.cL)
q(A.fm,[A.hx,A.kx,A.ke,A.ko,A.hp,A.hi,A.jf,A.jq,A.hB,A.hm,A.hl,A.jx,A.iw,A.iX,A.iA])
r(A.bM,A.bN)
q(A.cP,[A.cN,A.bO])
q(A.bO,[A.dk,A.dm])
r(A.dl,A.dk)
r(A.cO,A.dl)
r(A.dn,A.dm)
r(A.ab,A.dn)
q(A.cO,[A.el,A.em])
q(A.ab,[A.en,A.eo,A.ep,A.eq,A.er,A.cQ,A.bf])
r(A.dx,A.eJ)
q(A.c0,[A.au,A.D])
q(A.bu,[A.bZ,A.cc])
q(A.O,[A.dv,A.aI,A.dd,A.cr,A.c6])
r(A.c3,A.dv)
q(A.ad,[A.c4,A.c7])
q(A.eI,[A.aY,A.d9])
r(A.dj,A.bZ)
r(A.bs,A.dd)
q(A.f2,[A.eF,A.eV])
r(A.dt,A.bR)
r(A.di,A.dt)
r(A.hd,A.dV)
r(A.ie,A.hd)
r(A.ig,A.dX)
q(A.al,[A.bP,A.cD])
q(A.j6,[A.cX,A.hH,A.bI,A.ek,A.aO,A.ao,A.cB,A.aU,A.aM])
r(A.bU,A.b8)
r(A.dR,A.U)
q(A.dR,[A.e8,A.aP,A.bS])
q(A.dQ,[A.eM,A.eX])
q(A.X,[A.bp,A.V])
q(A.t,[A.bX,A.aN,A.bV])
r(A.bW,A.hV)
q(A.V,[A.de,A.da,A.c5,A.ce])
r(A.hJ,A.hQ)
r(A.fx,A.dY)
r(A.b3,A.cU)
r(A.c_,A.hJ)
q(A.dC,[A.eG,A.eW])
r(A.fd,A.fW)
r(A.dP,A.bo)
r(A.eO,A.bV)
r(A.at,A.eO)
s(A.dD,A.t)
s(A.dk,A.t)
s(A.dl,A.cC)
s(A.dm,A.t)
s(A.dn,A.cC)
s(A.bZ,A.eE)
s(A.cc,A.f_)})()
var v={G:typeof self!="undefined"?self:globalThis,typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{a:"int",K:"double",mE:"num",B:"String",S:"bool",z:"Null",r:"List",d:"Object",aS:"Map",m:"JSObject"},mangledNames:{},types:["~()","~(m)","z()","a()","~(a)","w<~>()","a(a1,a)","~(~())","z(m)","~(@)","~(d,J)","z(d,J)","w<~>(dg)","~(~)","a(a1)","~(ew,a,a,a)","m()","~(bw)","z(@)","~(d?)","a(U,a)","@()","a(U,a,a,a)","a(a1,a,a,a3)","~(ew,a)","w<ai<~>>()","~(an)","w<bo>()","~(@,J)","a(U,a,a)","@(B)","a(U?,a,a)","~(d[J?])","@(@)","z(@,J)","a(a1,a3)","~(d?,d?)","a(a1,a,a)","a(a())","~(~(a,B,a),a,a,a,a3)","~(a,@)","z(a9,a9)","a(ew,a,a,a,a)","a(a(a),a)","a(kX,a)","a(kX,a,a)","d?(~)","B(d?)","m(p<d?>)","~(a,B,a)","w<z>()","z(~())","m(m?)","~(b5)","w<~>(a,bi)","w<~>(a)","bi()","w<m>(B)","~(lu)","z(aA)","w<z>(m)","m(d)","z(d?,J)","B?(d?)","c2()","m(m)","w<0^>(0^())<d?>","w<m>()","S(B)","@(@,B)","w<ai<an>>()","~(n,G,n,~())","S()","S(c1)","~(a3,a)","w<b9>()","0&(d?,J)","~(be<m>)","a1?(U,a,a,a,a)","~(be<aT<B>>)","z(~)","~(aT<B>)","a(@,@)","S(d?)","~(n?,G?,n,d,J)","0^(n?,G?,n,0^())<d?>","0^(n?,G?,n,0^(1^),1^)<d?,d?>","0^(n?,G?,n,0^(1^,2^),1^,2^)<d?,d?,d?>","0^()(n,G,n,0^())<d?>","0^(1^)(n,G,n,0^(1^))<d?,d?>","0^(1^,2^)(n,G,n,0^(1^,2^))<d?,d?,d?>","H?(n,G,n,d,J?)","~(n?,G?,n,~())","d0(n,G,n,az,~())","d0(n,G,n,az,~(d0))","~(n,G,n,B)","n(n?,G?,n,d6?,aS<d?,d?>?)","~(b8)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{"2;":(a,b)=>c=>c instanceof A.W&&a.b(c.a)&&b.b(c.b),"2;basicSupport,supportsReadWriteUnsafe":(a,b)=>c=>c instanceof A.dr&&a.b(c.a)&&b.b(c.b),"2;controller,sync":(a,b)=>c=>c instanceof A.ds&&a.b(c.a)&&b.b(c.b),"2;file,outFlags":(a,b)=>c=>c instanceof A.ca&&a.b(c.a)&&b.b(c.b),"2;result,resultCode":(a,b)=>c=>c instanceof A.eU&&a.b(c.a)&&b.b(c.b)}}
A.oI(v.typeUniverse,JSON.parse('{"a9":"aR","et":"aR","bj":"aR","qH":"bN","p":{"r":["1"],"I":[],"o":["1"],"m":[]},"ee":{"S":[],"C":[]},"cF":{"z":[],"C":[]},"I":{"m":[]},"aR":{"I":[],"m":[]},"ed":{"cV":[]},"hw":{"p":["1"],"r":["1"],"I":[],"o":["1"],"m":[]},"cG":{"K":[]},"cE":{"K":[],"a":[],"C":[]},"ef":{"K":[],"C":[]},"aQ":{"B":[],"C":[]},"aX":{"q":["2"]},"b6":{"aX":["1","2"],"q":["2"],"q.E":"2"},"db":{"b6":["1","2"],"aX":["1","2"],"o":["2"],"q":["2"],"q.E":"2"},"d8":{"t":["2"],"r":["2"],"aX":["1","2"],"o":["2"],"q":["2"]},"ay":{"d8":["1","2"],"t":["2"],"r":["2"],"aX":["1","2"],"o":["2"],"q":["2"],"t.E":"2","q.E":"2"},"bb":{"F":[]},"o":{"q":["1"]},"af":{"o":["1"],"q":["1"]},"d_":{"af":["1"],"o":["1"],"q":["1"],"af.E":"1","q.E":"1"},"bd":{"q":["2"],"q.E":"2"},"cy":{"bd":["1","2"],"o":["2"],"q":["2"],"q.E":"2"},"aD":{"af":["2"],"o":["2"],"q":["2"],"af.E":"2","q.E":"2"},"d4":{"q":["1"],"q.E":"1"},"aF":{"q":["1"],"q.E":"1"},"bH":{"aF":["1"],"o":["1"],"q":["1"],"q.E":"1"},"cz":{"o":["1"],"q":["1"],"q.E":"1"},"cv":{"aS":["1","2"]},"cw":{"cv":["1","2"],"aS":["1","2"]},"dh":{"q":["1"],"q.E":"1"},"cR":{"aG":[],"F":[]},"eg":{"F":[]},"eC":{"F":[]},"du":{"J":[]},"ex":{"F":[]},"ba":{"cL":["1","2"],"aS":["1","2"]},"aB":{"o":["1"],"q":["1"],"q.E":"1"},"cH":{"o":["a6<1,2>"],"q":["a6<1,2>"],"q.E":"a6<1,2>"},"bM":{"I":[],"m":[],"b5":[],"C":[]},"bN":{"I":[],"m":[],"b5":[],"C":[]},"cP":{"I":[],"m":[]},"f1":{"b5":[]},"cN":{"I":[],"m":[],"C":[]},"bO":{"aa":["1"],"I":[],"m":[]},"cO":{"t":["K"],"r":["K"],"aa":["K"],"I":[],"o":["K"],"m":[]},"ab":{"t":["a"],"r":["a"],"aa":["a"],"I":[],"o":["a"],"m":[]},"el":{"t":["K"],"r":["K"],"aa":["K"],"I":[],"o":["K"],"m":[],"C":[],"t.E":"K"},"em":{"t":["K"],"r":["K"],"aa":["K"],"I":[],"o":["K"],"m":[],"C":[],"t.E":"K"},"en":{"ab":[],"t":["a"],"r":["a"],"aa":["a"],"I":[],"o":["a"],"m":[],"C":[],"t.E":"a"},"eo":{"ab":[],"t":["a"],"r":["a"],"aa":["a"],"I":[],"o":["a"],"m":[],"C":[],"t.E":"a"},"ep":{"ab":[],"t":["a"],"r":["a"],"aa":["a"],"I":[],"o":["a"],"m":[],"C":[],"t.E":"a"},"eq":{"ab":[],"t":["a"],"r":["a"],"aa":["a"],"I":[],"o":["a"],"m":[],"C":[],"t.E":"a"},"er":{"ab":[],"t":["a"],"r":["a"],"aa":["a"],"I":[],"o":["a"],"m":[],"C":[],"t.E":"a"},"cQ":{"ab":[],"t":["a"],"r":["a"],"aa":["a"],"I":[],"o":["a"],"m":[],"C":[],"t.E":"a"},"bf":{"ab":[],"bi":[],"t":["a"],"r":["a"],"aa":["a"],"I":[],"o":["a"],"m":[],"C":[],"t.E":"a"},"eJ":{"F":[]},"dx":{"aG":[],"F":[]},"H":{"F":[]},"d7":{"ct":["1"]},"cb":{"q":["1"],"q.E":"1"},"cS":{"F":[]},"c0":{"ct":["1"]},"au":{"c0":["1"],"ct":["1"]},"D":{"c0":["1"],"ct":["1"]},"k":{"w":["1"]},"bZ":{"bu":["1"]},"cc":{"bu":["1"]},"c3":{"dv":["1"],"O":["1"],"O.T":"1"},"c4":{"ad":["1"],"ai":["1"],"ad.T":"1"},"ad":{"ai":["1"],"ad.T":"1"},"dv":{"O":["1"]},"aI":{"O":["1"],"O.T":"1"},"dj":{"bZ":["1"],"bu":["1"],"be":["1"]},"dd":{"O":["2"]},"c7":{"ad":["2"],"ai":["2"],"ad.T":"2"},"bs":{"dd":["1","2"],"O":["2"],"O.T":"2"},"f2":{"n":[]},"eF":{"n":[]},"eV":{"n":[]},"cf":{"G":[]},"di":{"bR":["1"],"aT":["1"],"o":["1"]},"bc":{"q":["1"],"q.E":"1"},"t":{"r":["1"],"o":["1"]},"cL":{"aS":["1","2"]},"cJ":{"af":["1"],"o":["1"],"q":["1"],"af.E":"1","q.E":"1"},"bR":{"aT":["1"],"o":["1"]},"dt":{"bR":["1"],"aT":["1"],"o":["1"]},"r":{"o":["1"]},"aT":{"o":["1"]},"dN":{"F":[]},"aG":{"F":[]},"al":{"F":[]},"bP":{"F":[]},"cD":{"F":[]},"d1":{"F":[]},"eB":{"F":[]},"as":{"F":[]},"dW":{"F":[]},"es":{"F":[]},"cY":{"F":[]},"eY":{"J":[]},"bU":{"b8":[]},"e8":{"U":[]},"eM":{"d2":[],"a1":[]},"dR":{"U":[]},"dQ":{"d2":[],"a1":[]},"bp":{"X":["bp"],"X.E":"bp"},"bX":{"t":["bn"],"r":["bn"],"o":["bn"],"t.E":"bn"},"cr":{"O":["1"],"O.T":"1"},"aP":{"U":[]},"V":{"X":["V"]},"eN":{"d2":[],"a1":[]},"de":{"V":[],"X":["V"],"X.E":"V"},"da":{"V":[],"X":["V"],"X.E":"V"},"c5":{"V":[],"X":["V"],"X.E":"V"},"ce":{"V":[],"X":["V"],"X.E":"V"},"bS":{"U":[]},"eX":{"d2":[],"a1":[]},"aN":{"t":["d?"],"r":["d?"],"o":["d?"],"t.E":"d?"},"c_":{"lv":[]},"eG":{"dC":["m"]},"eW":{"dC":["m"]},"dP":{"bo":[]},"at":{"bV":["a"],"t":["a"],"r":["a"],"o":["a"],"t.E":"a"},"bV":{"t":["1"],"r":["1"],"o":["1"]},"eO":{"bV":["a"],"t":["a"],"r":["a"],"o":["a"]},"c6":{"O":["1"],"O.T":"1"},"dc":{"ai":["1"]},"nI":{"r":["a"],"o":["a"]},"bi":{"r":["a"],"o":["a"]},"oe":{"r":["a"],"o":["a"]},"nG":{"r":["a"],"o":["a"]},"oc":{"r":["a"],"o":["a"]},"nH":{"r":["a"],"o":["a"]},"od":{"r":["a"],"o":["a"]},"nB":{"r":["K"],"o":["K"]},"nC":{"r":["K"],"o":["K"]}}'))
A.oH(v.typeUniverse,JSON.parse('{"d5":1,"eA":1,"e3":1,"cC":1,"dD":2,"ei":1,"bK":1,"bO":1,"eZ":1,"cS":2,"f_":1,"eE":1,"eI":1,"aY":1,"dp":1,"bv":1,"dt":1,"dV":2,"dX":2,"e4":1,"ek":1,"nf":1}'))
var u={c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type",n:"Tried to operate on a released prepared statement",g:"max must be in range 0 < max \u2264 2^32, was "}
var t=(function rtii(){var s=A.ap
return{b9:s("nf<d?>"),cO:s("cr<p<d?>>"),dI:s("b5"),fM:s("lu"),fg:s("lv"),eT:s("b8"),d:s("b9"),dn:s("ct<m>"),eX:s("e0"),Q:s("o<@>"),C:s("F"),gk:s("e5"),b8:s("qE"),em:s("w<m>"),aQ:s("w<z>"),U:s("w<aA?>"),bU:s("w<bW?>"),bd:s("aP"),M:s("p<w<~>>"),W:s("p<m>"),f:s("p<d>"),fS:s("p<+controller,sync(be<an>,S)>"),e:s("p<+controller,sync(be<~>,S)>"),gQ:s("p<+(aU,B)>"),bb:s("p<bU>"),db:s("p<ai<@>>"),x:s("p<ai<~>>"),s:s("p<B>"),bj:s("p<c_>"),bZ:s("p<c1>"),f6:s("p<eS>"),ey:s("p<bw>"),t:s("p<K>"),gn:s("p<@>"),gz:s("p<H?>"),c:s("p<d?>"),T:s("cF"),m:s("m"),V:s("a3"),g:s("a9"),aU:s("aa<@>"),aX:s("I"),bN:s("bc<bp>"),au:s("bc<V>"),q:s("r<m>"),r:s("r<B>"),j:s("r<@>"),g6:s("aS<B,a>"),a:s("bM"),eB:s("ab"),Z:s("bf"),P:s("z"),K:s("d"),gT:s("qJ"),bQ:s("+()"),eJ:s("+(m,cu)"),ab:s("+(aU,B)"),f9:s("+(S,m)"),eN:s("+basicSupport,supportsReadWriteUnsafe(S,S)"),cf:s("+(m?,m)"),v:s("bS"),l:s("J"),aY:s("ai<an>"),w:s("ai<~>"),N:s("B"),aF:s("d0"),dm:s("C"),eK:s("aG"),fQ:s("at"),p:s("bi"),ak:s("bj"),fL:s("U"),b:s("d2"),n:s("bW"),u:s("bo"),bS:s("au<a>"),h:s("au<~>"),bD:s("c2"),O:s("bq<m>"),Y:s("c6<m>"),cp:s("k<aA>"),_:s("k<m>"),gp:s("k<0&>"),k:s("k<S>"),eI:s("k<@>"),B:s("k<a>"),D:s("k<~>"),c3:s("aI<m>"),aT:s("aI<aT<B>>"),fs:s("aZ<an,~()>"),fK:s("aZ<~,S()>"),bq:s("aZ<~,~()>"),eP:s("D<aA>"),G:s("D<m>"),fa:s("D<S>"),F:s("D<~>"),y:s("S"),i:s("K"),z:s("@"),E:s("@(d)"),R:s("@(d,J)"),S:s("a"),eH:s("w<z>?"),J:s("aA?"),A:s("m?"),X:s("d?"),dk:s("B?"),fN:s("at?"),ex:s("bW?"),a6:s("S?"),cD:s("K?"),I:s("a?"),cg:s("mE?"),o:s("mE"),H:s("~"),L:s("~()"),d5:s("~(d)"),da:s("~(d,J)")}})();(function constants(){var s=hunkHelpers.makeConstList
B.a5=J.eb.prototype
B.c=J.p.prototype
B.b=J.cE.prototype
B.h=J.aQ.prototype
B.a6=J.a9.prototype
B.a7=J.I.prototype
B.ae=A.cN.prototype
B.d=A.bf.prototype
B.F=J.et.prototype
B.v=J.bj.prototype
B.j=new A.b3("Operation was cancelled")
B.J=new A.e3()
B.w=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.K=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof HTMLElement == "function";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.P=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var userAgent = navigator.userAgent;
    if (typeof userAgent != "string") return hooks;
    if (userAgent.indexOf("DumpRenderTree") >= 0) return hooks;
    if (userAgent.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.L=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.O=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.N=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.M=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.x=function(hooks) { return hooks; }

B.Q=new A.es()
B.f=new A.hR()
B.y=new A.ie()
B.e=new A.ig()
B.k=new A.j5()
B.R=new A.jy()
B.a=new A.eV()
B.i=new A.eY()
B.S=new A.k1()
B.T=new A.k2()
B.af={}
B.aK=new A.cw(B.af,[],A.ap("cw<d?,d?>"))
B.U=new A.kc()
B.a_=new A.az(0)
B.l=new A.aO("x",1,"opfsExternalLocks")
B.z=new A.aO("y",2,"opfsExternalLocksWorkaround")
B.A=new A.bI("/database",0,"database")
B.B=new A.bI("/database-journal",1,"journal")
B.n=new A.ao(0,"unknown")
B.o=new A.ao(1,"integer")
B.p=new A.ao(2,"bigInt")
B.q=new A.ao(3,"float")
B.r=new A.ao(4,"text")
B.t=new A.ao(5,"blob")
B.u=new A.ao(6,"$null")
B.I=new A.ao(7,"boolean")
B.C=s([B.n,B.o,B.p,B.q,B.r,B.t,B.u,B.I],A.ap("p<ao>"))
B.V=new A.aM(0,"ok")
B.W=new A.aM(1,"getAutoCommit")
B.X=new A.aM(2,"executeBatch")
B.Y=new A.aM(3,"updateSubscriptionManagement")
B.Z=new A.aM(4,"notifyUpdates")
B.a8=s([B.V,B.W,B.X,B.Y,B.Z],A.ap("p<aM>"))
B.a3=new A.cB(0,"database")
B.a4=new A.cB(1,"journal")
B.D=s([B.a3,B.a4],A.ap("p<cB>"))
B.a2=new A.aO("s",0,"opfsShared")
B.a0=new A.aO("i",3,"indexedDb")
B.a1=new A.aO("m",4,"inMemory")
B.a9=s([B.a2,B.l,B.z,B.a0,B.a1],A.ap("p<aO>"))
B.E=s([],t.s)
B.aa=s([],t.c)
B.ab=s([B.A,B.B],A.ap("p<bI>"))
B.G=new A.aU(0,"opfs")
B.H=new A.aU(1,"indexedDb")
B.aj=new A.aU(2,"inMemory")
B.ac=s([B.G,B.H,B.aj],A.ap("p<aU>"))
B.ad=new A.ek(11,"simpleSuccessResponse")
B.aL=new A.hH(2,"readWriteCreate")
B.m=new A.dr(!1,!1)
B.ag=new A.cX(0,"insert")
B.ah=new A.cX(1,"update")
B.ai=new A.cX(2,"delete")
B.ak=A.aq("b5")
B.al=A.aq("qA")
B.am=A.aq("nB")
B.an=A.aq("nC")
B.ao=A.aq("nG")
B.ap=A.aq("nH")
B.aq=A.aq("nI")
B.ar=A.aq("d")
B.as=A.aq("oc")
B.at=A.aq("od")
B.au=A.aq("oe")
B.av=A.aq("bi")
B.aw=new A.aW(14)
B.ax=new A.aW(522)
B.ay=new A.aW(778)
B.az=new A.k3(B.a,A.pV())
B.aA=new A.k4(B.a,A.pW())
B.aB=new A.f3(B.a,A.pX())
B.aC=new A.k5(B.a,A.pY())
B.aD=new A.k6(B.a,A.pZ())
B.aE=new A.k7(B.a,A.q_())
B.aF=new A.k8(B.a,A.q0())
B.aG=new A.ka(B.a,A.q2())
B.aH=new A.kb(B.a,A.q3())
B.aI=new A.k9(B.a,A.q1())
B.aJ=new A.f4(B.a,A.q4())})();(function staticFields(){$.jA=null
$.bA=A.v([],t.f)
$.pv=null
$.lK=null
$.lr=null
$.lq=null
$.mB=null
$.mw=null
$.mI=null
$.ks=null
$.kz=null
$.lh=null
$.jF=A.v([],A.ap("p<r<d>?>"))
$.ch=null
$.dF=null
$.dG=null
$.l9=!1
$.l=B.a
$.jG=null})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal,r=hunkHelpers.lazy
s($,"qC","mN",()=>A.kt("_$dart_dartClosure"))
s($,"qB","bG",()=>A.kt("_$dart_dartClosure_dartJSInterop"))
s($,"r8","n7",()=>B.a.al(new A.kB(),A.ap("w<~>")))
s($,"r3","n5",()=>A.v([new J.ed()],A.ap("p<cV>")))
s($,"qL","mQ",()=>A.aH(A.id({
toString:function(){return"$receiver$"}})))
s($,"qM","mR",()=>A.aH(A.id({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"qN","mS",()=>A.aH(A.id(null)))
s($,"qO","mT",()=>A.aH(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(q){return q.message}}()))
s($,"qR","mW",()=>A.aH(A.id(void 0)))
s($,"qS","mX",()=>A.aH(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(q){return q.message}}()))
s($,"qQ","mV",()=>A.aH(A.m0(null)))
s($,"qP","mU",()=>A.aH(function(){try{null.$method$}catch(q){return q.message}}()))
s($,"qU","mZ",()=>A.aH(A.m0(void 0)))
s($,"qT","mY",()=>A.aH(function(){try{(void 0).$method$}catch(q){return q.message}}()))
s($,"qW","ll",()=>A.oh())
s($,"qG","cn",()=>$.n7())
s($,"qF","mO",()=>A.oo(!1,B.a,t.y))
s($,"r_","n2",()=>A.nZ(4096))
s($,"qY","n0",()=>new A.jZ().$0())
s($,"qZ","n1",()=>new A.jY().$0())
s($,"qX","n_",()=>typeof FinalizationRegistry=="function"?FinalizationRegistry:null)
s($,"r0","kK",()=>A.mF(B.ar))
s($,"r1","n3",()=>Symbol("jsBoxedDartObjectProperty"))
s($,"qI","mP",()=>{var q=new A.jz(new DataView(new ArrayBuffer(A.p2(8))))
q.ew()
return q})
s($,"qz","f8",()=>$.mP())
s($,"r4","n6",()=>A.nV(A.v([A.kY("files"),A.kY("blocks")],t.s)))
s($,"qD","kJ",()=>{var q,p,o=A.aC(t.N,A.ap("bI"))
for(q=0;q<2;++q){p=B.ab[q]
o.q(0,p.c,p)}return o})
s($,"r2","n4",()=>B.R)
r($,"qV","dL",()=>{var q="navigator"
return A.nN(A.nO(A.kv(A.mJ(),q),A.kY("locks")))?A.kv(A.kv(A.mJ(),q),"locks"):null})})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({SharedArrayBuffer:A.bN,ArrayBuffer:A.bM,ArrayBufferView:A.cP,DataView:A.cN,Float32Array:A.el,Float64Array:A.em,Int16Array:A.en,Int32Array:A.eo,Int8Array:A.ep,Uint16Array:A.eq,Uint32Array:A.er,Uint8ClampedArray:A.cQ,CanvasPixelArray:A.cQ,Uint8Array:A.bf})
hunkHelpers.setOrUpdateLeafTags({SharedArrayBuffer:true,ArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.bO.$nativeSuperclassTag="ArrayBufferView"
A.dk.$nativeSuperclassTag="ArrayBufferView"
A.dl.$nativeSuperclassTag="ArrayBufferView"
A.cO.$nativeSuperclassTag="ArrayBufferView"
A.dm.$nativeSuperclassTag="ArrayBufferView"
A.dn.$nativeSuperclassTag="ArrayBufferView"
A.ab.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$3$1=function(a){return this(a)}
Function.prototype.$2$1=function(a){return this(a)}
Function.prototype.$1$1=function(a){return this(a)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$3$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$2$2=function(a,b){return this(a,b)}
Function.prototype.$2$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$1$2=function(a,b){return this(a,b)}
Function.prototype.$5=function(a,b,c,d,e){return this(a,b,c,d,e)}
Function.prototype.$3$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$2$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$3$6=function(a,b,c,d,e,f){return this(a,b,c,d,e,f)}
Function.prototype.$2$5=function(a,b,c,d,e){return this(a,b,c,d,e)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=A.qn
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()
//# sourceMappingURL=db_worker.js.map
