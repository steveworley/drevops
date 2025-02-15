<?php

namespace Drupal\Tests\ys_core\Functional;

/**
 * Class YsCoreExampleFunctionalTest.
 *
 * Example test case class.
 *
 * @group YsCore
 */
class YsCoreExampleFunctionalTest extends YsCoreFunctionalTestBase {

  /**
   * Tests addition.
   *
   * @dataProvider dataProviderAdd
   * @group addition
   */
  public function testAdd($a, $b, $expected, $expectExceptionMessage = NULL) {
    if ($expectExceptionMessage) {
      $this->expectException(\Exception::class);
      $this->expectExceptionMessage($expectExceptionMessage);
    }

    // Replace below with a call to your class method.
    $actual = $a + $b;

    $this->assertEquals($expected, $actual);
  }

  /**
   * Data provider for testAdd().
   */
  public function dataProviderAdd() {
    return [
      [0, 0, 0],
      [1, 1, 2],
    ];
  }

  /**
   * Tests subtraction.
   *
   * @dataProvider dataProviderSubtract
   * @group subtraction
   */
  public function testSubtract($a, $b, $expected, $expectExceptionMessage = NULL) {
    if ($expectExceptionMessage) {
      $this->expectException(\Exception::class);
      $this->expectExceptionMessage($expectExceptionMessage);
    }

    // Replace below with a call to your class method.
    $actual = $a - $b;

    $this->assertEquals($expected, $actual);
  }

  /**
   * Data provider for testSubtract().
   */
  public function dataProviderSubtract() {
    return [
      [0, 0, 0],
      [1, 1, 0],
      [2, 1, 1],
    ];
  }

  /**
   * Tests multiplication.
   *
   * @dataProvider dataProviderMultiplication
   * @group multiplication
   * @group skipped
   */
  public function testMultiplication($a, $b, $expected, $expectExceptionMessage = NULL) {
    if ($expectExceptionMessage) {
      $this->expectException(\Exception::class);
      $this->expectExceptionMessage($expectExceptionMessage);
    }

    // Replace below with a call to your class method.
    $actual = $a * $b;

    $this->assertEquals($expected, $actual);
  }

  /**
   * Data provider for testMultiplication().
   */
  public function dataProviderMultiplication() {
    return [
      [0, 0, 0],
      [1, 1, 1],
      [2, 1, 2],
    ];
  }

}
