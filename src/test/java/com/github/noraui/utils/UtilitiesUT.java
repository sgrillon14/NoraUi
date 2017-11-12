package com.github.noraui.utils;

import java.util.HashMap;

import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import com.github.noraui.Runner;
import com.github.noraui.application.page.demo.DemoPage;
import com.github.noraui.cucumber.injector.NoraUiInjector;
import com.github.noraui.cucumber.injector.NoraUiInjectorSource;
import com.github.noraui.exception.TechnicalException;
import com.github.noraui.utils.Context;
import com.github.noraui.utils.Utilities;
import com.google.inject.Inject;

public class UtilitiesUT {

    @Inject
    DemoPage demoPage;

    @Before
    public void setUp() throws TechnicalException {
        NoraUiInjector.resetInjector();
        new NoraUiInjectorSource().getInjector();
    }

    @After
    public void tearDown() {
        NoraUiInjector.resetInjector();
    }

    @Test
    public void testGetLocatorValue() {
        // prepare mock
        Context.iniFiles = new HashMap<>();
        Context.initApplicationDom(Runner.class.getClassLoader(), "V1", this.demoPage.getApplication());

        // run test
        String value = Utilities.getSelectorValue(this.demoPage.getApplication(), this.demoPage.getPageKey() + this.demoPage.xpathContainPercentChar, 1);
        Assert.assertEquals("OK", ".//input[@name='%%Surrogate_LstPrestComp']/following-sibling::label[1]/input", value);
    }

}
