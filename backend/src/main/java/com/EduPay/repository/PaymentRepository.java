package com.EduPay.repository;

import com.EduPay.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;


@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {


    List<Payment> findByStudentId(Long studentId);


    Optional<Payment> findByGatewayOrderId(String gatewayOrderId);


    Optional<Payment> findByGatewayPaymentId(String gatewayPaymentId);


    List<Payment> findByRecordedById(Long recordedById);
}
