[TOC]

# Springboot后台处理跨域方法

```java
public class GlobalCorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @SuppressWarnings("NonAsciiCharacters")
            @Override
            //重写父类提供的跨域请求处理的接口
            public void addCorsMappings(CorsRegistry registry) {
                //添加映射路径
                registry.addMapping("/**")
                        //放行哪些原始域
                        .allowedOrigins("http://localhost:8080", "http://localhost:3000")
                        //是否发送Cookie信息
                        .allowCredentials(true)
                        //放行哪些原始域(请求方式)
                        .allowedMethods("GET", "POST", "PUT", "DELETE")
                        //放行哪些原始域(头部信息)
                        .allowedHeaders("*")
                        //暴露哪些头部信息（因为跨域访问默认不能获取全部头部信息）
                        .exposedHeaders("*");
            }
        };
    }
}
```

# mybatis-config.xml

```xml-dtd
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <typeAliases>
        <typeAlias type="com.zm.study.domain.SysUser" alias="sysUser"/>
    </typeAliases>
    <mappers>
        <mapper resource="com/zm/study/mapper/SysUserMapper.xml"/>
    </mappers>
</configuration>
```

# mybatis-mapper.xml

```xml-dtd
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.zm.study.mapper.SysUserMapper">
    <resultMap id="sysUserResultMap" type="sysUser">
        <id property="userId" column="user_id"/>
        <result property="userName" column="user_name"/>
        <result property="nickName" column="nick_name"/>
    </resultMap>
    <select id="selectSysUsers" resultMap="sysUserResultMap">
        select user_id,
               user_name,
               nick_name
        from sys_user;
    </select>
</mapper>
```

